# spec/channels/room_channel_spec.rb
require 'rails_helper'

RSpec.describe RoomChannel, type: :channel do
  let(:user) { create(:user) }

  before do
    stub_connection current_user: user
  end

  it 'subscribes to room_channel' do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from('room_channel')
  end

  it 'creates a tweet when speaking' do
    subscribe
    expect {
      perform :speak, message: 'テストツイート'
    }.to change(Tweet, :count).by(1)
    tweet = Tweet.last
    expect(tweet.message).to eq('テストツイート')
    expect(tweet.user_id).to eq(user.id)
  end
end
