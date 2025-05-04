# db/migrate/YYYYMMDDHHMMSS_migrate_line_uid_to_uid.rb
class MigrateLineUidToUid < ActiveRecord::Migration[7.0]
  def change
    # line_uidをuidに移行
    execute "UPDATE users SET uid = line_uid WHERE uid IS NULL AND line_uid IS NOT NULL"
    # line_uidカラムを削除
    remove_column :users, :line_uid, :string
  end
end
