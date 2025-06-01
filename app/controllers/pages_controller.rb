# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  def welcome
    @line_friend_link = "line://ti/p/@946voeaz" # 実際の公式アカウントIDに置き換え
  end
  
  def dashboard
  end
end
