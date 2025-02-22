class CreateGoals < ActiveRecord::Migration[7.2]
  def change
    create_table :goals do |t|
      t.string :title
      t.integer :status
      t.integer :category
      t.date :due_date
      t.datetime :reminder_at

      t.timestamps
    end
  end
end
