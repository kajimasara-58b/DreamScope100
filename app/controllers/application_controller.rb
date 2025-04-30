class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_user_id_cookie

  private

  def require_login
    # ログインしていない場合の処理
    redirect_to login_path unless logged_in?
  end

  def logged_in?
    # ログイン状態をチェックする処理
  end

  # ログイン後のリダイレクト先を指定
  def after_sign_in_path_for(resource)
    dashboard_index_path # ダッシュボードにリダイレクト
  end

  # ログイン時にクッキーに user_id を設定
  def set_user_id_cookie
    if user_signed_in?
      cookies.signed[:user_id] = { value: current_user.id, expires: 1.hour.from_now }
    else
      cookies.delete(:user_id)
    end
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
