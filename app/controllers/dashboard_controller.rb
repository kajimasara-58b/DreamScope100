class DashboardController < ApplicationController
  def index
    @achieved_goals = Goal.where(status: '済').count
  end
end
