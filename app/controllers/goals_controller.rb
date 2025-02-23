class GoalsController < ApplicationController
  def new
  end

  def index
    @goals = Goal.all
  end
end
