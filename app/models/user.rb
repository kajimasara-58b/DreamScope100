class User < ApplicationRecord
  has_many :goals, dependent: :destroy
  has_many :tweets, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:line]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email || "line_user_#{auth.uid}@example.com" # LINEはメールアドレス取得に申請が必要なので仮のメールを設定
      user.password = Devise.friendly_token[0, 20] # ランダムなパスワードを生成
      user.name = auth.info.name # LINEの表示名を取得
    end
  end

  validates :email, uniqueness: true
end
