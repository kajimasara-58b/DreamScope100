class GoalsController < ApplicationController
  before_action :authenticate_user! # ログインしていない場合、ログインページにリダイレクト
  def new
    @goal = Goal.new
    @goal.assign_attributes(session[:goal_params]) if session[:goal_params]
    session.delete(:goal_params) # セッションから削除
  end

  def index
    @goals = Goal.where(user_id: current_user.id)
  end

  def create
    @goal = Goal.new(goal_params)
    @goal.user_id = current_user.id

    # メールorパスワード未設定チェック
    if current_user.email_password_unset?
      flash.now[:email_password_unset] = "メールアドレスとパスワードを設定すると目標作成ができるようになります！"
      Rails.logger.info("Flash email_password_unset set: #{flash.now[:email_password_unset]}")
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("flash", partial: "shared/flash")
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
      end
      return
    end

    # バリデーションエラー時
    unless @goal.valid?
      session[:goal_params] = goal_params # 作成内容をセッションに保存
      flash.now[:alert] = @goal.errors.full_messages # 具体的なエラーメッセージをフラッシュに
      render :new, status: :unprocessable_entity
    end

    if @goal.save
      session.delete(:goal_params) # 成功時にセッションをクリア
      redirect_to goals_path, notice: "目標を作成しました"
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
      flash.now[:alert] = @goal.errors.full_messages # 具体的なエラーメッセージをフラッシュに
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    @goal = Goal.find(params[:id])
    @goal.destroy
    session.delete(:goal_params) # 削除後にセッションをクリア
    redirect_to goals_path, notice: "目標を削除しました"
  end

  private

  def goal_params
    params.require(:goal).permit(:id, :title, :due_date, :status, :user_id, :category, :notify_enabled, :notify_days_before) # 必要な属性を指定すること
  end
end
