class User < ApplicationRecord
  has_many :goals, dependent: :destroy
  has_many :tweets, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :line ]

  # スコープ
  scope :active, -> { where(active: true) }

  # バリデーション
  validates :name, presence: true
  validates :uid, uniqueness: { scope: :provider, allow_nil: true, conditions: -> { where(active: true) } } 
  validates :email, uniqueness: { allow_nil: true }, if: -> { email.present? && provider == "email" }
  validates :email, presence: true, if: -> { provider == "email" } # 通常ログインで必須
  validates :provider, presence: true, on: :save # 登録時はコールバックで設定
  validates :uid, presence: true, uniqueness: { scope: :provider, conditions: -> { where(active: true) } }, on: :save

  # デフォルト値を設定
  before_validation :set_default_provider_and_uid, on: :create

  # メールアドレスの必須性をproviderに応じて設定
  def email_required?
    provider == "email"
  end

  def password_required?
    provider == "email" && super
  end

  def self.from_omniauth(auth)
    find_by(provider: auth.provider, uid: auth.uid, active: true) ||
    create_with_omniauth(auth)
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email || "line_#{auth.uid}@example.com"
      user.name = auth.info.name || "LINE User"
      user.password = Devise.friendly_token[0, 20]
      user.active = true
    end
  end

  private

  def set_default_provider_and_uid
    self.provider ||= "email" if provider.blank? # 通常ログインの場合
    self.uid ||= SecureRandom.uuid if uid.blank? # 一意の値を生成
  end

  def encrypted_password_changed?
    return false if provider == "line" && encrypted_password.blank?
    super
  end

  def generate_link_token
    self.link_token = SecureRandom.urlsafe_base64(32)
    self.link_token_sent_at = Time.current
  end
end
