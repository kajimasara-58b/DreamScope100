class Goal < ApplicationRecord
  belongs_to :user
  # バリデーションやアソシエーションなどがあればここに
  enum status: { 未: 0, 済: 1 }
  enum category: { 健康: 0, 美容: 1, 運動・フィットネス: 2, 仕事: 3, 学習: 4, ライフスタイル: 5, 旅行・アクティビティ: 6, お金（貯金・投資・資産形成など）: 7, 人間関係（家族・友人・恋愛など）: 8, その他: 9 }
  validates :title, presence: true, length: { maximum: 40, message: "は40文字以内にしてください" } 
  validates :status, presence: true
  validates :due_date, presence: true
  validates :category, presence: true

  # ユーザーごとの目標数制限（100個まで）のカスタムバリデーション
  validate :goals_limit_per_user

  private

  def goals_limit_per_user
    return unless user # userがnilの場合はスキップ

    # 現在のユーザーの目標数をカウント（削除された目標は含まない）
    existing_goals_count = user.goals.count
    if new_record? && existing_goals_count >= 100
      errors.add(:base, "登録できる目標は100個までです")
    elsif !new_record? && user.goals.where.not(id: id).count >= 100
      errors.add(:base, "登録できる目標は100個までです")
    end
  end
end
