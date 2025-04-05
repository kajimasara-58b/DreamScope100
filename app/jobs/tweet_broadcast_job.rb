class TweetBroadcastJob < ApplicationJob
  queue_as :default

  def perform(tweet)
    # Do something later
    Rails.logger.info "Broadcasting tweet: #{tweet.inspect}"
    ActionCable.server.broadcast('room_channel', { tweet: render_tweet(tweet) })
  end

   
  private
   
  def render_tweet(tweet)
    ApplicationController.renderer.render partial: "shared/message", locals: { tweet: tweet }
  end
end
