class TweetBroadcastJob < ApplicationJob
  queue_as :default

  def perform(tweet, current_user_id = nil)
    # Do something later
    Rails.logger.info "Broadcasting tweet: #{tweet.inspect}"
    ActionCable.server.broadcast("room_channel", {
      tweet: render_tweet(tweet, current_user_id),
      tweet_id: tweet.id
    })
  end
  
  private

  def render_tweet(tweet, current_user_id)
    ApplicationController.render(
      partial: 'shared/message',
      locals: { tweet: tweet, is_current_user: current_user_id && tweet.user_id == current_user_id }
    )
  end
end
