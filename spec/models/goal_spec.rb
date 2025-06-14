# spec/models/goal_spec.rb
require 'rails_helper'

RSpec.describe Goal, type: :model do
  describe 'バリデーション' do
    let(:goal) { build(:goal) }

    it 'タイトルが必須であること' do
      goal.title = nil
      expect(goal).not_to be_valid
      expect(goal.errors[:title]).to include('を入力してください')
    end

    it 'タイトルが40文字以内でなければならない' do
      goal.title = 'A' * 41
      expect(goal).not_to be_valid
      expect(goal.errors[:title]).to include('は40文字以内にしてください')
    end

    it 'ステータスが必須であること' do
      goal.status = nil
      expect(goal).not_to be_valid
      expect(goal.errors[:status]).to include('を入力してください')
    end

    it '期限日が必須であること' do
      goal.due_date = nil
      expect(goal).not_to be_valid
      expect(goal.errors[:due_date]).to include('を入力してください')
    end

    it 'カテゴリーが必須であること' do
      goal.category = nil
      expect(goal).not_to be_valid
      expect(goal.errors[:category]).to include('を入力してください')
    end

    context '通知が有効な場合' do
      let(:goal) { build(:goal, notify_enabled: true, notify_days_before: 3) }

      it '通知日数が必須であること' do
        goal.notify_days_before = nil
        expect(goal).not_to be_valid
        expect(goal.errors[:notify_days_before]).to include('を入力してください')
      end

      it '通知日数が0より大きいこと' do
        goal.notify_days_before = 0
        expect(goal).not_to be_valid
        expect(goal.errors[:notify_days_before]).to include('は0より大きくなければなりません')
      end
    end

    context '通知が無効な場合' do
      it '通知日数がなくても有効であること' do
        goal.notify_days_before = nil
        expect(goal).to be_valid
      end
    end

    describe '目標数制限' do
      let(:user) { create(:user) }
      let!(:goals) { create_list(:goal, 100, user: user) }

      it 'ユーザーが100個以上の目標を登録できないこと' do
        new_goal = build(:goal, user: user)
        expect(new_goal).not_to be_valid
        expect(new_goal.errors[:base]).to include('登録できる目標は100個までです')
      end

      it '既存の目標を更新する場合は制限に影響されないこと' do
        existing_goal = goals.first
        existing_goal.title = '更新されたタイトル'
        expect(existing_goal).to be_valid
      end
    end
  end
end
