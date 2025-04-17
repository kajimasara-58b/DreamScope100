class CreateGoalSummaryImages < ActiveRecord::Migration[7.2]
  def change
    create_table :goal_summary_images do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
