class UsersController < ApplicationController
  before_action :authenticate_user!, except: [ :link_account ] # ログインしていない場合、ログインページにリダイレクト
  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to users_show_path, notice: "登録情報を更新しました"
    else
      session[:user_params] = user_params # 編集内容をセッションに保存
      render :edit, status: :unprocessable_entity
    end
  end

  def check_email
    email = params[:email]
    existing_user = User.where(email: email).where.not(id: current_user.id).first
    if existing_user
      render json: { conflict: true, message: "このメールアドレスは既に登録されています。既存アカウントと結びつけますか？" }
    else
      render json: { conflict: false }
    end
  end

  def initiate_link_account
    email = params[:email]
    existing_user = User.where(email: email).where.not(id: current_user.id).first
    if existing_user
      begin
        # emailは更新せず、トークンのみ保存
        if current_user.update_columns(link_token: SecureRandom.urlsafe_base64(32), link_token_sent_at: Time.current)
          UserMailer.link_account_email(current_user, email).deliver_later
          redirect_to user_path(current_user), notice: "認証メールを送信しました。メール内のリンクをクリックして結びつけを完了してください。"
        else
          redirect_to edit_user_path(current_user), alert: "ユーザー情報の更新に失敗しました。"
        end
      rescue ActiveRecord::RecordNotUnique => e
        Rails.logger.error("Unique constraint violation: #{e.message}")
        redirect_to edit_user_path(current_user), alert: "メールアドレスの更新に失敗しました。別のメールアドレスを試してください。"
      rescue StandardError => e
        Rails.logger.error("Failed to process link account: #{e.message}")
        redirect_to edit_user_path(current_user), alert: "処理中にエラーが発生しました。もう一度お試しください。"
      end
    else
      redirect_to edit_user_path(current_user), alert: "無効なメールアドレスです。"
    end
  end

  def link_account
    Rails.logger.debug("Link account params: token=#{params[:token]}, email=#{params[:email]}")
    user = User.find_by(link_token: params[:token])
    if user && user.link_token_sent_at > 15.minutes.ago
      Rails.logger.debug("User found: id=#{user.id}, email=#{user.email}")
      existing_user = User.active.where(email: params[:email]).where.not(id: user.id).first
      if existing_user
        Rails.logger.debug("Existing user found: id=#{existing_user.id}, email=#{existing_user.email}")
        begin
          ActiveRecord::Base.transaction do
            user.update!(
              active: false,
              link_token: nil, # トークンをクリア
              link_token_sent_at: nil
            )
            existing_user.update!(
              name: existing_user.name || user.name, # 名前を統合（必要に応じて）
              email: params[:email], # メールアドレスを確実に設定
              provider: "line",
              uid: user.uid
            )
          end
          Rails.logger.debug("Signing in existing user: id=#{existing_user.id}")
          sign_in(existing_user, event: :authentication)
          redirect_to user_path(existing_user), notice: "アカウントを結びつけました。"
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Failed to link account: #{e.message}")
          redirect_to new_user_session_path, alert: "アカウントの結びつけに失敗しました：#{e.message}"
        end
      else
        Rails.logger.error("Existing user not found for email: #{params[:email]}")
        redirect_to new_user_session_path, alert: "アカウントが見つかりません。"
      end
    else
      Rails.logger.error("Invalid or expired link: token=#{params[:token]}, email=#{params[:email]}, user_found=#{user.present?}")
      redirect_to new_user_session_path, alert: "リンクが無効または期限切れです。"
    end
  end

  def edit_password
    @user = current_user
    if @user.email.blank?
      flash[:alert] = "メールアドレスを設定してください。"
      redirect_to users_show_path
    end
  end

  def update_password
    @user = current_user
    if @user.update(password_params)
      @user.update(is_dummy_password: false)
      sign_in(@user, event: :authentication, bypass: true)
      redirect_to users_show_path, notice: "パスワードを更新しました。"
    else
      flash[:alert] = "パスワードの更新に失敗しました。入力内容を確認してください。"
      render :edit_password, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :provider, :line_uid) # 必要な属性のみ指定
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
