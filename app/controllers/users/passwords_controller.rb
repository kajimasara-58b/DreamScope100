# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # ログイン状態に関係なく edit と update アクションを許可
  skip_before_action :require_no_authentication, only: [ :edit, :update ]

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    super
  end

  # PUT /resource/password
  def update
    @user = User.reset_password_by_token(user_params)

    if @user.errors.empty?
      # パスワード更新が成功した場合、ログアウトしてログインページにリダイレクト
      sign_out(@user)
      redirect_to new_user_session_path, notice: "パスワードが正常に更新されました。再度ログインしてください。"
    else
      # 更新に失敗した場合（バリデーションエラーなど）、フォームを再表示
      render :edit, status: :unprocessable_entity
    end
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :reset_password_token) # 必要な属性を指定すること
  end
end
