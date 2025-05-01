class User < ApplicationRecord
  has_many :goals, dependent: :destroy
  has_many :tweets, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:line]

  # バリデーション
  # validates :provider, presence: true
  # validates :uid, presence: true, uniqueness: { scope: :provider }

  # デフォルト値を設定
  before_validation :set_default_provider_and_uid, on: :create

  def self.from_omniauth(auth)
    # 1. providerとuidで既存ユーザーを検索
    user = find_by(provider: auth.provider, uid: auth.uid)

    # 2. 見つからない場合、メールアドレスで既存ユーザーを検索
    unless user
      user = find_by(email: auth.info.email)
      if user
        # 既存ユーザーが見つかった場合、providerとuidを更新
        user.update(provider: auth.provider, uid: auth.uid)
      end
    end

    # 3. それでも見つからない場合、新規ユーザーを作成
    user ||= first_or_create(provider: auth.provider, uid: auth.uid) do |new_user|
      new_user.email = auth.info.email || "default_#{auth.uid}@example.com"
      new_user.password = Devise.friendly_token[0, 20]
      new_user.name = auth.info.name
    end

    user
  end

  validates :email, uniqueness: true

  private

  def set_default_provider_and_uid
    self.provider ||= "email" # 通常ログインの場合
    self.uid ||= SecureRandom.uuid # 一意の値を生成
  end
end
