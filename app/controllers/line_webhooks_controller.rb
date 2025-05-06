class LineWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token # CSRFトークンを無効化

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless LineBot.client.validate_signature(body, signature)
      Rails.logger.error("LINE Webhook: Invalid signature")
      head :bad_request
      return
    end

    events = LineBot.client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Follow
        user_id = event['source']['userId']
        Rails.logger.info("Friend added: userId=#{user_id}")
        # 連携用のURLを送信
        message = {
          type: 'text',
          text: "LINE通知を有効にするには以下のリンクをクリックしてください：http://localhost:3000/line_connect?user_id=#{user_id}"
        }
        response = LineBot.client.push_message(user_id, message)
        Rails.logger.info("連携用メッセージを送信しました：#{response.body}")
      end
    end

    head :ok
  end
end