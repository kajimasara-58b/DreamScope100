# spec/system/goal_creation_spec.rb
require 'rails_helper'

RSpec.describe 'Goal Creation', type: :system do
  let(:user) { create(:user) }
  let(:goal) { build(:goal, user: user) } # FactoryBotで有効な目標

  before do
    sign_in user
  end

  it '目標を作成できる' do
    visit new_goal_path
    fill_in 'goal-title-input-new', with: goal.title # id指定
    fill_in 'goal-due-date-input-new', with: goal.due_date.strftime('%Y-%m-%d')
    select goal.status.humanize, from: 'goal_status' # name="goal[status]"
    select goal.category.humanize, from: 'goal_category' # name="goal[category]"
    click_button '作成'
    expect(page).to have_content(goal.title)
    expect(Goal.exists?(title: goal.title)).to be true
  end

  it 'タイトルが空だと作成できない' do
    visit new_goal_path
    fill_in 'goal-title-input-new', with: ''
    fill_in 'goal-due-date-input-new', with: goal.due_date.strftime('%Y-%m-%d')
    select goal.status.humanize, from: 'goal_status'
    select goal.category.humanize, from: 'goal_category'
    click_button '作成'
    expect(Goal.exists?(title: '')).to be false
  end
end
