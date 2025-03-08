class Goal < ApplicationRecord
  belongs_to :user
  # バリデーションやアソシエーションなどがあればここに
  enum status: { 未: 0, 済: 1 }
  validates :title, presence: true
  validates :status, presence: true
  validates :due_date, presence: true

  # ユーザーごとの目標数制限（100個まで）のカスタムバリデーション
  validate :goals_limit_per_user

  private

  def goals_limit_per_user
    return unless user # userがnilの場合はスキップ

    # 現在のユーザーの目標数をカウント（削除された目標は含まない）
    existing_goals_count = user.goals.count
    if new_record? && existing_goals_count >= 100
      errors.add(:base, '登録できる目標は100個までです。')
    elsif !new_record? && user.goals.where.not(id: id).count >= 100
      errors.add(:base, '登録できる目標は100個までです。')
    end
  end
end
