# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :authenticate_user!, except: [ :new, :create ]
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate(auth_options)
    if resource
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      session[:user_id] = resource.id
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      flash.now[:warning] = "メールアドレスまたはパスワードが正しくありません"
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super
    flash[:notice] = "ログアウトしました"
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def after_sign_in_path_for(resource)
    # リダイレクト先を指定する
    dashboard_index_path
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :remember_me)
  end
end
