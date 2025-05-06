class AddLineNoticeIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :line_notice_id, :string
    add_index :users, :line_notice_id, unique: true
  end
end
