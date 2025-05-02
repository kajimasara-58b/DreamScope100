class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def line
    auth = request.env["omniauth.auth"]
    @user = User.find_by(line_uid: auth.uid)
    Rails.logger.info "LINE Auth Info: #{auth.to_json}" # デバッグ用ログ

    if @user
      # 2回目以降のログイン
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "LINE") if is_navigational_format?
    else
      # 初回ログイン
      session[:line_auth] = { uid: auth.uid, name: auth.info.name || "LINEユーザー" }
      redirect_to user_email_registration_path
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "LINEログインに失敗しました"
  end
end
