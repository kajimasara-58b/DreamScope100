class GoalsController < ApplicationController
  def new
    @goal = Goal.new
    @goal.assign_attributes(session[:goal_params]) if session[:goal_params]
    session.delete(:goal_params) # セッションから削除
  end

  def index
    @goals = Goal.all
  end

  def create
    @goal = Goal.new(goal_params)
    if @goal.save
      redirect_to goals_path, notice: "目標を作成しました"
    else
      session[:goal_params] = goal_params # 編集内容をセッションに保存
      flash[:alert] = "目標の更新に失敗しました。入力内容を確認してください。"
      redirect_to new_goal_path
    end
  end

  def show
    @goal = Goal.find(params[:id])
  end

  def edit
    @goal = Goal.find(params[:id])
    @goal.assign_attributes(session[:goal_params]) if session[:goal_params]
    session.delete(:goal_params) # セッションから削除
  end

  def update
    @goal = Goal.find(params[:id])
    if @goal.update(goal_params)
      redirect_to goal_path(@goal), notice: "目標を更新しました"
    else
      session[:goal_params] = goal_params # 編集内容をセッションに保存
      flash[:alert] = "目標の更新に失敗しました。入力内容を確認してください。"
      redirect_to edit_goal_path(@goal)
    end
  end


  def destroy
    @goal = Goal.find(params[:id])
    @goal.destroy

    redirect_to goals_path, notice: "目標を削除しました"
  end

  private

  def goal_params
    params.require(:goal).permit(:id, :title, :due_date, :status) # 必要な属性を指定すること
  end
end
