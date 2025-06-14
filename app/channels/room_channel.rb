class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    if current_user.email_password_unset?
      error_message = "メールアドレスとパスワードを設定するとメッセージの送信ができるようになります！"
      ActionCable.server.broadcast("room_channel", {
        error: true,
        flash: {
          alert: error_message,
          email_password_unset: true
        }
      })
      return
    end

    begin
      Rails.logger.info "Creating tweet with message: #{data['message']}"
      tweet = Tweet.create!(message: data["message"], user: current_user)
      Rails.logger.info "Tweet created: #{tweet.inspect}"
      TweetBroadcastJob.perform_later(tweet, current_user.id)
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to create tweet: #{e.message}")
      ActionCable.server.broadcast("room_channel", {
        error: true,
        flash: {
          alert: e.message,
          email_password_unset: false
        }
      })
    end
  end
end