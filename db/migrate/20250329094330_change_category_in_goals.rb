class ChangeCategoryInGoals < ActiveRecord::Migration[7.2]
  def change
    change_column :goals, :category, :integer, null: false
  end
end
