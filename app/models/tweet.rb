class Tweet < ApplicationRecord
    validates :message, presence: true
    after_create_commit { TweetBroadcastJob.perform_now self }
end
