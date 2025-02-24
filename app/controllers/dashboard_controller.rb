class DashboardController < ApplicationController
  def index
    @achieved_goals = Goal.where(status: "済", user_id: current_user.id).count
  end
end
