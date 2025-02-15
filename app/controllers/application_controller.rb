class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def require_login
    # ログインしていない場合の処理
    redirect_to login_path unless logged_in?
  end

  def logged_in?
    # ログイン状態をチェックする処理
  end
end
