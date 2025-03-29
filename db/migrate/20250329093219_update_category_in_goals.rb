class UpdateCategoryInGoals < ActiveRecord::Migration[7.2]
  def up
    Goal.where(category: nil).update_all(category: 0)
  end
end
