class ChangeActiveColumnInUsers < ActiveRecord::Migration[7.0]
  def change
    # 1. 既存のNULL値をtrueに更新
    execute "UPDATE users SET active = true WHERE active IS NULL"
    # 2. デフォルト値とNOT NULL制約を適用
    change_column :users, :active, :boolean, default: true, null: false
  end
end
