class GoalsController < ApplicationController
  def new
    @goal = Goal.new
  end

  def index
    @goals = Goal.all
  end

  def create
    @goal = Goal.new(goal_params)
    if @goal.save
      redirect_to goals_path, notice: "目標を作成しました"
    else
      flash[:alert] = "目標の作成に失敗しました。入力内容を確認してください。"
      redirect_to new_goal_path
    end
  end

  def show
    @goal = Goal.find(params[:id]) 
  end

  private

  def goal_params
    params.require(:goal).permit(:id, :title, :due_date, :status) # 必要な属性を指定すること
  end
end
