require 'rails_helper'

RSpec.describe 'User Registration', type: :system do
  let(:user_attributes) do
    {
      name: '梶間紗羅',
      email: 'newuser@example.com',
      password: 'password123'
    }
  end

  it '有効な情報でユーザー登録できる' do
    visit new_user_registration_path
    fill_in 'user_name', with: user_attributes[:name]
    fill_in 'user_email', with: user_attributes[:email]
    fill_in 'user_password', with: user_attributes[:password]
    fill_in 'user_password_confirmation', with: user_attributes[:password]
    click_button '登録'
    expect(page).to have_content('アカウント登録が完了しました')
    expect(current_path).to eq(dashboard_index_path)
    expect(User.exists?(email: user_attributes[:email])).to be true
  end

  it 'パスワードが一致しないと登録できない' do
    visit new_user_registration_path
    fill_in 'user_name', with: user_attributes[:name]
    fill_in 'user_email', with: user_attributes[:email]
    fill_in 'user_password', with: user_attributes[:password]
    fill_in 'user_password_confirmation', with: 'different123'
    click_button '登録'
    expect(page).to have_content('が一致しません')
    expect(current_path).to eq(user_registration_path)
    expect(User.exists?(email: user_attributes[:email])).to be false
  end
end
