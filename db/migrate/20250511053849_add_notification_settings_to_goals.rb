class AddNotificationSettingsToGoals < ActiveRecord::Migration[7.2]
  def change
    # すでに存在するかチェックしてから追加
    unless column_exists?(:goals, :notify_enabled)
      add_column :goals, :notify_enabled, :boolean, default: false, null: false
    end
    unless column_exists?(:goals, :notify_days_before)
      add_column :goals, :notify_days_before, :integer
    end
  end
end
