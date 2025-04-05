class CreateTweets < ActiveRecord::Migration[7.2]
  def change
    create_table :tweets do |t|
      t.text :message, null: false

      t.timestamps
    end
  end
end
