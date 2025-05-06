require "line/bot"

module LineBot
  def self.client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV["LINE_NOTICE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_NOTICE_CHANNEL_TOKEN"]
    end
  end
end
