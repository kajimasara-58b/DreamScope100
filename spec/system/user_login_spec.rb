# spec/system/user_login_spec.rb
require 'rails_helper'

RSpec.describe 'User Login', type: :system do
  let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

  it '有効なメールアドレスとパスワードでログインできる' do
    visit new_user_session_path
    fill_in 'メールアドレス', with: 'test@example.com'
    fill_in 'パスワード', with: 'password123'
    click_button 'ログイン'
    expect(page).to have_content('ログインしました。')
    expect(current_path).to eq(dashboard_index_path)
  end

  it '無効なパスワードでログインできない' do
    visit new_user_session_path
    fill_in 'メールアドレス', with: 'test@example.com'
    fill_in 'パスワード', with: 'wrongpassword'
    click_button 'ログイン'
    expect(page).to have_content('メールアドレスまたはパスワードが正しくありません')
    expect(current_path).to eq(new_user_session_path)
  end
end