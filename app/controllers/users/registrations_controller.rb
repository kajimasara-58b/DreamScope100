# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super do |resource|
      if resource.persisted?
        sign_out(resource) # 自動ログイン解除
        redirect_to new_user_session_path, notice: "登録が完了しました。ログインしてください。" and return
      end
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  # def update
  #   super
  # end

  def send_password_reset
    @user = User.find_by(name: params[:user][:name], email: params[:user][:email])

    if @user && @user.valid_password?(params[:user][:current_password])
      @user.send_reset_password_instructions
      redirect_to registration_done_path
    else
      flash[:alert] = "ユーザー名またはメールアドレス、現在のパスワードが正しくありません。"
      render :edit # フォームを再表示
    end
  end

  def done
    # 特に何も処理しない　ビューを表示するだけ
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
