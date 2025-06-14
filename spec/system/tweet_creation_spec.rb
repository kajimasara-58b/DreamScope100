# spec/system/tweet_creation_spec.rb
require 'rails_helper'

RSpec.describe 'Tweet Creation', type: :system, js: true do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

  before do
    sign_in user
    # ActiveJobを即時実行
    ActiveJob::Base.queue_adapter = :inline
    # RoomChannel#speakをモック
    allow_any_instance_of(RoomChannel).to receive(:speak) do |channel, data|
      if data['message'].present?
        tweet = Tweet.create!(message: data['message'], user: user)
        ActionCable.server.broadcast('room_channel', tweet: tweet.attributes)
      end
    end
  end

  after do
    # ActiveJob設定をリセット
    ActiveJob::Base.queue_adapter = :test
  end

  #  it 'ツイートを投稿できる' do
  #    visit tweet_index_path
  #    fill_in 'message-input', with: 'テストツイート'
  #    click_button '送信'
  #    expect(page).to have_content('テストツイート', wait: 5)
  #    expect(Tweet.exists?(message: 'テストツイート')).to be_true
  #  end
end
