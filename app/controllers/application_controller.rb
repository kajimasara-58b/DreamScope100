class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

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

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
