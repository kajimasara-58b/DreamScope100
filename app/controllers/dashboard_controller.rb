class DashboardController < ApplicationController
  before_action :authenticate_user! # ログインしていない場合、ログインページにリダイレクト

  def index
    @achieved_goals = Goal.where(status: "済", user_id: current_user.id).count
    @unachieved_goals = Goal.where(status: "未", user_id: current_user.id).count
    @registered_goals = Goal.where(user_id: current_user.id).count
  end

  def data
    @user = current_user
    render json: {
      achieved_goals: Goal.where(user_id: @user.id, status: 1).count,
      unachieved_goals: Goal.where(user_id: @user.id, status: 0).count,
      registered_goals: Goal.where(user_id: @user.id).count
    }
  end
end
