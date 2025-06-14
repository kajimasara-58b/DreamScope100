# spec/system/line_login_spec.rb
require 'rails_helper'

RSpec.describe 'Line Login', type: :system do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:line] = OmniAuth::AuthHash.new(
      provider: 'line',
      uid: 'line-uid-123',
      info: { name: 'LINEユーザー', email: nil }
    )
  end

  it 'LINEログインで認証できる' do
    visit new_user_session_path
    click_button 'LINEでログイン'
    expect(current_path)==(root_path)
  end
end