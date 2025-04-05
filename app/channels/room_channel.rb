class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    begin
      Tweet.create! message: data['message']
    rescue ActiveRecord::RecordInvalid => e
      ActionCable.server.broadcast 'room_channel', message: "Error: #{e.message}"
    end
  end
end
