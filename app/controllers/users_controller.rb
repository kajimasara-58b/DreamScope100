class UsersController < ApplicationController
  before_action :authenticate_user! # ログインしていない場合、ログインページにリダイレクト
  def show
    @user = current_user
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_show_path, notice: "登録情報を更新しました"
    else
      session[:user_params] = user_params # 編集内容をセッションに保存
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:id, :email, :provider) # 必要な属性を指定すること
  end
end
