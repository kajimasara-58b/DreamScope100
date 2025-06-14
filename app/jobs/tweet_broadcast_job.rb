class TweetBroadcastJob < ApplicationJob
  queue_as :default

  def perform(tweet, sender_user_id)
    Rails.logger.info "[TweetBroadcastJob] sender_user_id: #{sender_user_id}, tweet.user_id: #{tweet.user_id}"
    ActionCable.server.broadcast("room_channel", {
      tweet: ApplicationController.render(
        partial: "shared/message",
        locals: { tweet: tweet, is_current_user: nil }, # 判定をクライアントに委ねる
        formats: [ :html ]
      ),
      tweet_id: tweet.id,
      user_id: tweet.user_id.to_s, # 受信側で比較用
      date: tweet.created_at.in_time_zone("Tokyo").to_date.to_s
    })
  end
end
