class User < ApplicationRecord
  attr_accessor :require_password_for_email_registration

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
  validates :uid, uniqueness: { scope: :provider, allow_nil: true, conditions: -> { where(active: true) } }, if: -> { provider == "line" }
  validates :email, uniqueness: { allow_nil: true }, if: -> { email.present? && provider == "email" }
  validates :email, presence: true, if: -> { provider == "email" } # 通常ログインで必須
  validates :provider, presence: true, on: :save # 登録時はコールバックで設定
  validates :uid, presence: true, if: -> { provider == "line" } # LINEログインでのみ必須
  validates :is_dummy_password, inclusion: { in: [ true, false ] }, allow_nil: false

  # デフォルト値を設定
  before_validation :set_default_provider_and_uid, on: :create
  before_validation :set_default_is_dummy_password, on: :create
  before_validation :normalize_email

  # メールアドレスの必須性をproviderに応じて設定
  def email_required?
    provider == "email"
  end

  def password_required?
    # ● 通常の email ログイン時 OR
    # ● LINEログイン後にメール＋パスワード登録をするフローで
    #   controller からフラグを立てたとき
    (provider == "email" && super) ||
      require_password_for_email_registration == true
  end

  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid, active: true)
    return user if user

    # アカウント作成を遅延させ、セッションに仮ユーザー情報を保存
    {
      provider: auth.provider,
      uid: auth.uid,
      name: auth.info.name || "LINE User",
      email: auth.info.email,
      temporary: true
    }
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email.presence # nil or empty string -> nil
      user.name = auth.info.name || "LINE User"
      user.password = Devise.friendly_token[0, 20] if user.provider == "email"
      user.active = true
      user.is_dummy_password = (user.provider == "line")
    end
  end

  def email_password_unset?
    email.blank? || encrypted_password.blank?
  end

  private

  def set_default_provider_and_uid
    self.provider ||= "email" if provider.blank? # 通常ログインの場合
    self.uid ||= SecureRandom.uuid if uid.blank? # 一意の値を生成
  end

  def set_default_is_dummy_password
    if provider == "line" && password.nil?
      self.is_dummy_password = true
    elsif is_dummy_password.nil?
      self.is_dummy_password = false
    end
  end

  def encrypted_password_changed?
    return false if provider == "line" && encrypted_password.blank?
    super
  end

  def generate_link_token
    self.link_token = SecureRandom.urlsafe_base64(32)
    self.link_token_sent_at = Time.current
  end

  def normalize_email
    self.email = email.presence # 空文字やnilをnilに統一
  end
end
