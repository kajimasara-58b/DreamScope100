class AddUserIdToGoals < ActiveRecord::Migration[7.2]
  def change
    add_column :goals, :user_id, :integer
  end
end
