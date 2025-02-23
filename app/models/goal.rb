class Goal < ApplicationRecord
  # バリデーションやアソシエーションなどがあればここに
  enum status: { 未: 0, 済: 1 }
  validates :title, presence: true
  validates :status, presence: true
  validates :due_date, presence: true
end
