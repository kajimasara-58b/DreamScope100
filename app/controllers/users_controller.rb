class UsersController < ApplicationController
  before_action :authenticate_user! # ログインしていない場合、ログインページにリダイレクト
  def show
    @user = current_user
  end

  def edit
  end

  def update
  end

end
