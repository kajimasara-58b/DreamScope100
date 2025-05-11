class CheckGoalNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("目標通知のチェックを開始します")

    goals = Goal.where(notify_enabled: true)
    today = Date.today

    goals.each do |goal|
      notification_date = goal.due_date - goal.notify_days_before.days
      if notification_date == today
        SendGoalNotificationJob.perform_later(goal.id)
        Rails.logger.info("通知をスケジュールしました：目標「#{goal.title}」（達成予定日：#{goal.due_date}）")
      end
    end

    Rails.logger.info("目標通知のチェックを終了しました")
  end
end