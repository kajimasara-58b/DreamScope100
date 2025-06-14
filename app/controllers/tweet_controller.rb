class TweetController < ApplicationController
  before_action :authenticate_user!

  def index
    @tweets = Tweet.includes(:user).order(created_at: :asc)
    @current_user = current_user
    Rails.logger.info "Current user ID in index: #{@current_user.id}"
  end
end