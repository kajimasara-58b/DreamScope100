# spec/system/goal_editing_spec.rb
require 'rails_helper'

RSpec.describe 'Goal Editing', type: :system do
  let(:user) { create(:user) }
  let(:goal) { create(:goal, user: user, title: '元の目標') }

  before do
    sign_in user
  end

  it '目標を編集できる' do
    visit edit_goal_path(goal)
    fill_in 'goal-title-input-edit', with: goal.title # id指定
    fill_in 'goal-due-date-input-edit', with: goal.due_date.strftime('%Y-%m-%d')
    select goal.status.humanize, from: 'goal_status' # name="goal[status]"
    select goal.category.humanize, from: 'goal_category' # name="goal[category]"
    click_button '更新'
    expect(page).to have_content('目標を更新しました')
    expect(goal.reload.title).to eq('元の目標')
  end

  it 'タイトルが空だと編集できない' do
    visit edit_goal_path(goal)
    fill_in 'goal-title-input-edit', with: ''
    click_button '更新'
    expect(Goal.exists?(title: '')).to be false
    expect(goal.reload.title).to eq('元の目標')
  end
end
