class ModifyUsersForLineLogin < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :line_uid, :string
    change_column_null :users, :email, true
    add_index :users, :line_uid, unique: true
  end
end