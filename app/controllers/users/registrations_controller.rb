# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, except: [ :email, :update_email, :skip_email_registration ]
  skip_before_action :require_no_authentication, only: [ :email, :update_email, :skip_email_registration ]

  # LINE認証済みユーザー用画面
  def email
    unless session[:line_auth]
      return redirect_to new_user_session_path, alert: "LINEログイン情報がありません。"
    end

    # セッションからLINE情報取り出し
    auth = session[:line_auth]
    # ① 既存LINEユーザーを探す
    @user = User.active.find_by(provider: "line", uid: auth["uid"])

    # ② 見つからなければ未保存のインスタンスを生成
    unless @user
      @user = User.new(
        provider: "line",
        uid:      auth["uid"],
        name:     auth["name"] || "LINEユーザー",
        active:   true,
        # is_dummy_password は before_validation でセットするなら不要
      )
    end

    render :email
  end

  def update_email
    auth = session[:line_auth] or
    return redirect_to(new_user_session_path, alert: "LINEログイン情報がありません。")

    # ① 既存LINEユーザー or 新規Userインスタンス
    @user = User.active.find_by(provider: "line", uid: auth["uid"]) ||
            User.new(provider: "line", uid: auth["uid"], name: auth["name"], active: true)

    # ここで「メール＋パスワード登録フローです」とフラグを立てる
    @user.require_password_for_email_registration = true

    # フォームから渡ってくる email/password/confirmation/name をマスアサイン
    @user.assign_attributes(user_params)

    if @user.save
      # 保存成功→自動ログイン＆セッション削除
      sign_in(@user, event: :authentication)
      session.delete(:line_auth)
      redirect_to params[:redirect_to] || welcome_path, notice: "メールアドレスとパスワードを登録しました。"
    else
      # 保存失敗→エラーメッセージとともにフォーム再表示
      flash.now[:alert] = @user.errors.full_messages.join("、")
      render :email, status: :unprocessable_entity
    end
  end

  def skip_email_registration
    auth = session[:line_auth]
    unless auth
      return redirect_to new_user_session_path, alert: "LINEログイン情報がありません。"
    end

    # ① 既存のLINEユーザーを探す or 新規作成
    user = User.active.find_by(provider: "line", uid: auth["uid"])
    unless user
      user = User.create!(
        provider:          "line",
        uid:               auth["uid"],
        name:              auth["name"]  || "LINEユーザー",
        email:             nil, # 明示的にnilをセット
        active:            true,
        is_dummy_password: true
      )
    end

    # ② 仮ログイン状態（Devise で認証済み）にする
    sign_in(user, event: :authentication)

    # ③ セッションからLINE情報はもう不要なら削除
    session.delete(:line_auth)

    # ④ LINE公式アカウント友達登録へ
    redirect_to params[:redirect_to] || welcome_path, notice: "メールアドレス・パスワードの登録をスキップしました。「ユーザー情報」から設定できます。"
  end

  def create
    super do |resource|
      # オートログインに変更
      # if resource.persisted?
      #   sign_out(resource)
      #   redirect_to new_user_session_path, notice: "登録が完了しました。ログインしてください。" and return
      # end
    end
  end

  def edit
    super
  end

  def send_password_reset
    @user = User.active.find_by(name: params[:user][:name], email: params[:user][:email])
    if @user && @user.valid_password?(params[:user][:current_password])
      @user.send_reset_password_instructions
      redirect_to registration_done_path
    else
      flash[:alert] = "ユーザー名またはメールアドレス、現在のパスワードが正しくありません。"
      render :edit, status: :unprocessable_entity
    end
  end

  def done
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :email, :uid, :provider, :password, :password_confirmation ])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation) # 必要な属性のみ指定
  end
end
