class UsersController < ApplicationController
  before_action :authenticate_user!, except: [ :link_account, :line_link_account, :check_email, :initiate_link_account, :initiate_line_link_account ] # ログインしていない場合、ログインページにリダイレクト
  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    email = user_params[:email]&.strip&.downcase
    existing_user = User.active.where(email: email).where.not(id: @user.id).first

    if existing_user
      # メールアドレスが他のユーザーと重複する場合、結びつけプロセスを開始
      token = SecureRandom.urlsafe_base64(32)
      ActiveRecord::Base.transaction do
        @user.update_columns(link_token: token, link_token_sent_at: Time.current)
      end
      UserMailer.link_account_email(@user, email).deliver_later
      redirect_to user_path(@user), notice: "このメールアドレスは既に登録されています。認証メールを送信しました。メール内のリンクをクリックして結びつけを完了してください。"
    elsif @user.update(user_params)
      redirect_to users_show_path, notice: "登録情報を更新しました"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end


  def check_email
    email = params[:email]&.strip&.downcase
    unless email.present?
      Rails.logger.info "No email provided in check_email"
      render json: { conflict: false, message: "メールアドレスが入力されていません。" }, status: :bad_request
      return
    end

    # 現在のユーザーを除外して重複チェック
    existing_user = User.active.where(email: email).where.not(id: current_user&.id).first
    Rails.logger.info "Check email: #{email}, found user: #{existing_user&.id || 'none'}"
    if existing_user
      render json: { conflict: true, message: "このメールアドレスは既に登録されています。既存アカウントと結びつけますか？" }
    else
      render json: { conflict: false, message: "このメールアドレスは利用可能です。" }
    end
  end

  # LINEログインと同時にメールアドレス登録用のアクション
  def initiate_line_link_account
    email = params[:email]
    unless email.present?
      render json: { success: false, message: "メールアドレスを入力してください。" }, status: :unprocessable_entity
      return
    end

    existing_user = User.active.find_by(email: email)
    unless existing_user
      render json: { success: false, message: "このメールアドレスは登録されていません。" }, status: :unprocessable_entity
      return
    end

    unless session[:line_auth]
      render json: { success: false, message: "LINEログイン情報がありません。もう一度ログインしてください。" }, status: :unprocessable_entity
      return
    end

    existing_line_user = User.active.find_by(uid: session[:line_auth]["uid"], provider: "line")
    if existing_line_user && existing_line_user != existing_user
      render json: { success: false, message: "このLINEユーザーIDはすでに別のアカウントに登録されています。" }, status: :unprocessable_entity
      return
    end

    # 1) トークン発行とカラム更新はトランザクションで
    token = SecureRandom.urlsafe_base64(32)
    ActiveRecord::Base.transaction do
      existing_user.update_columns(
        link_token:         token,
        link_token_sent_at: Time.current
      )
      # セッションへの保存だけはトランザクション外でも OK ですが、このままでも構いません
      session[:line_auth][:link_email] = email
    end

    # 2) トランザクションがコミットされたあとでメール送信
    UserMailer.line_link_account_email(existing_user, email).deliver_later

    # 3) JSON レスポンスは最後に一度だけ
    render json: {
      success:      true,
      message:      "認証メールを送信しました。メール内のリンクをクリックして結びつけを完了してください。",
      redirect_url: new_user_session_path
    }
  rescue ActiveRecord::RecordNotUnique => e
    existing_user.update_columns(link_token: nil, link_token_sent_at: nil)
    render json: { success: false, message: "このLINEユーザーIDはすでに別のアカウントに登録されています。" }, status: :unprocessable_entity
  rescue StandardError => e
    existing_user.update_columns(link_token: nil, link_token_sent_at: nil)
    render json: { success: false, message: "処理中にエラーが発生しました。もう一度お試しください。" }, status: :unprocessable_entity
  end

  # LINEログインと同時にメールアドレス登録用のアクション
  def line_link_account
    Rails.logger.debug("Link account params: token=#{params[:token]}, email=#{params[:email]}")
    user = User.find_by(link_token: params[:token])
    if user && user.link_token_sent_at > 15.minutes.ago
      Rails.logger.debug("User found: id=#{user.id}, email=#{user.email}")
      begin
        line_user_id = session[:line_auth]&.dig("uid")
        line_notice_id = User.active.find_by(uid: line_user_id, provider: "line")&.line_notice_id
        ActiveRecord::Base.transaction do
          # LINEログインアカウントのline_notice_idをクリア（存在する場合）
          if line_user = User.active.find_by(uid: line_user_id, provider: "line")
            line_user.update!(line_notice_id: nil)
          end
          # 連携先アカウントを更新
          user.update!(
            name: user.name,
            email: params[:email],
            provider: "line",
            uid: line_user_id || user.uid,
            line_notice_id: line_notice_id, # line_notice_idを引き継ぐ
            link_token: nil,
            link_token_sent_at: nil
          )
          sign_in(user, event: :authentication)
          session.delete(:line_auth)
        end
        Rails.logger.debug("Signing in user: id=#{user.id}")
        redirect_to user_path(user), notice: "アカウントを結びつけました。"
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Failed to link account: #{e.message}")
        redirect_to new_user_session_path, alert: "アカウントの結びつけに失敗しました：#{e.message}"
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

  # LINEログイン後にメールアドレス登録用のアクション
  def initiate_link_account
    email = params[:email]
    existing_user = User.active.where(email: email).first
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

  # LINEログイン後にメールアドレス登録用のアクション
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
            line_notice_id = user.line_notice_id # line_notice_idを保存
            Rails.logger.debug("Transferring line_notice_id: #{line_notice_id}")
            user.update!(
              active: false,
              link_token: nil, # トークンをクリア
              link_token_sent_at: nil,
              line_notice_id: nil # ユニーク制約回避のためクリア
            )
            existing_user.update!(
              name: existing_user.name || user.name, # 名前を統合（必要に応じて）
              email: params[:email], # メールアドレスを確実に設定
              provider: "line",
              uid: user.uid,
              line_notice_id: line_notice_id # line_notice_idを引き継ぐ
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

  def email_password_unset?
    email.blank? || encrypted_password.blank? # Deviseの場合、encrypted_passwordでパスワード確認
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :provider, :line_uid, :password, :password_confirmation, :line_notice_id) # 必要な属性のみ指定
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
