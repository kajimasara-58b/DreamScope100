class SendGoalNotificationJob < ApplicationJob
  queue_as :default

  def perform(goal_id)
    goal = Goal.find_by(id: goal_id)
    return unless goal
    return unless goal.notify_enabled

    user = goal.user
    unless user.line_notice_id.present?
      Rails.logger.warn("LINE通知をスキップしました：ユーザー（#{user.email}）のline_notice_idが見つかりません")
      return
    end

    # LINEで通知メッセージを送信
    if send_line_notification(user.line_notice_id, goal)
      Rails.logger.info("LINE通知を送信しました：目標「#{goal.title}」（達成予定日：#{goal.due_date}）、ユーザー：#{user.email}")
    else
      Rails.logger.error("LINE通知に失敗しました：目標「#{goal.title}」（達成予定日：#{goal.due_date}）、ユーザー：#{user.email}")
    end
  end

  private

  def send_line_notification(user_id, goal)
    message = {
      type: "text",
      text: "目標「#{goal.title}」の達成予定日（#{goal.due_date}）が近づいています！💪"
    },
    {
      type: "sticker",
      packageId: "8515",
      stickerId: "16581265"
    }

    response = LineBot.client.push_message(user_id, message)
    if response.is_a?(Net::HTTPSuccess)
      true
    else
      Rails.logger.error("LINE通知の送信に失敗しました：#{response.body}")
      false
    end
  end
end