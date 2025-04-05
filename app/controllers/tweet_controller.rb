class TweetController < ApplicationController
  before_action :authenticate_user!

  def index
    @tweets = Tweet.order(created_at: :asc)
  end
end
