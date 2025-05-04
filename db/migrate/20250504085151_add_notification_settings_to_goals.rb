class AddNotificationSettingsToGoals < ActiveRecord::Migration[7.2]
  def change
    add_column :goals, :notify_enabled, :boolean, default: false, null: false
    add_column :goals, :notify_days_before, :integer
  end
end
