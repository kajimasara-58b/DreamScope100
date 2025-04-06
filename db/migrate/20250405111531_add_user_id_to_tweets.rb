class AddUserIdToTweets < ActiveRecord::Migration[7.0]
  def change
    add_reference :tweets, :user, null: true, foreign_key: true
  end
end
