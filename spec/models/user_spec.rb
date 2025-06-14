# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    context 'emailログインの場合' do
      let(:user) { build(:user, provider: 'email') }

      it '名前が必須であること' do
        user.name = nil
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include('を入力してください')
      end

      it 'メールアドレスが必須であること' do
        user.email = nil
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('メールアドレスを入力してください')
      end

      it 'メールアドレスがユニークであること' do
        create(:user, email: 'test@example.com', provider: 'email')
        user.email = 'test@example.com'
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('がすでに使用されています')
      end

      it 'プロバイダーがデフォルトでemailに設定されること' do
        user = build(:user, provider: nil)
        user.valid?
        expect(user.provider).to eq('email')
      end

      it 'is_dummy_passwordがデフォルトで設定されること' do
        user = build(:user, is_dummy_password: nil)
        user.valid?
        expect(user.is_dummy_password).to be false
      end
    end

    context 'LINEログインの場合' do
      let(:user) { build(:user, :line_user) }

      it '名前が必須であること' do
        user.name = nil
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include('を入力してください')
      end

      it 'uidが必須であること' do
        user = build(:user, :line_user, uid: nil)
        allow(user).to receive(:set_default_provider_and_uid) # コールバックを無効化
        expect(user).not_to be_valid
        expect(user.errors[:uid]).to include('ユーザーIDが設定されていません')
      end

      it 'uidがプロバイダー内でユニークであること' do
        create(:user, :line_user, uid: 'line-uid-123', provider: 'line')
        user.uid = 'line-uid-123'
        expect(user).not_to be_valid
        expect(user.errors[:uid]).to include('がすでに使用されています')
      end

      it 'メールアドレスがなくても有効であること' do
        user.email = nil
        expect(user).to be_valid
      end

      it 'line_notice_idがユニークであること' do
        create(:user, :line_user, line_notice_id: 'notice-123')
        user.line_notice_id = 'notice-123'
        expect(user).not_to be_valid
        expect(user.errors[:line_notice_id]).to include('は既に使用されています')
      end
    end

    context 'コールバックによるデフォルト値' do
      it 'プロバイダーが未設定の場合、emailに設定される' do
        user = build(:user, provider: nil)
        user.valid?
        expect(user.provider).to eq('email')
      end

      it 'uidが未設定の場合、UUIDが生成される' do
        user = build(:user, uid: nil)
        user.valid?
        expect(user.uid).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
      end

      it 'LINEログインでis_dummy_passwordがtrueに設定される' do
        user = build(:user, :line_user, password: nil)
        user.valid?
        expect(user.is_dummy_password).to be true
      end
    end
  end
end