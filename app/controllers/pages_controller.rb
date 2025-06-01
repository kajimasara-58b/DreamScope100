# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  before_action :authenticate_user!, only: [ :dashboard, :line_friend_add ] # ログイン必須

  def welcome
    @line_friend_link = "line://ti/p/@946voeaz" # 実際の公式アカウントIDに置き換え
  end

  def dashboard
  end

  def line_friend_add
    @line_friend_link = "line://ti/p/@946voeaz" # 実際の公式アカウントIDに置き換え
  end
end
