class TweetBroadcastJob < ApplicationJob
  queue_as :default

  def perform(tweet, current_user_id = nil)
    Rails.logger.info "Broadcasting tweet: #{tweet.inspect}"
    ActionCable.server.broadcast("room_channel", {
      tweet: {
        id: tweet.id,
        message: tweet.message,
        user_id: tweet.user_id,
        user_name: tweet.user.name || "Anonymous",
        created_at: tweet.created_at.in_time_zone('Tokyo').strftime("%H:%M")
      },
      tweet_id: tweet.id,
      user_id: tweet.user_id
    })
  end
end