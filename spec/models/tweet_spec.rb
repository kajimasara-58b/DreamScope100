# spec/models/tweet_spec.rb
require 'rails_helper'

RSpec.describe Tweet, type: :model do
  describe 'バリデーション' do
    let(:tweet) { build(:tweet) }

    it 'メッセージが必須であること' do
      tweet.message = nil
      expect(tweet).not_to be_valid
      expect(tweet.errors[:message]).to include('を入力してください')
    end

    it 'メッセージが入力されていれば有効であること' do
      expect(tweet).to be_valid
    end

    it 'ユーザーが必須であること' do
      tweet.user = nil
      expect(tweet).not_to be_valid
      expect(tweet.errors[:user]).to include('を入力してください')
    end
  end
end