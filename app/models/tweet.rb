class Tweet < ApplicationRecord
  belongs_to :user
  validates :message, presence: true
  validates :user_id, presence: true
end
