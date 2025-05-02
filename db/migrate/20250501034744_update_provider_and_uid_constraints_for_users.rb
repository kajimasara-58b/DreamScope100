class UpdateProviderAndUidConstraintsForUsers < ActiveRecord::Migration[7.1]
  def up
    # 既存データのNULL値を空文字列に更新
    User.where(provider: nil).update_all(provider: "")
    User.where(uid: nil).update_all(uid: "")

    # 通常ログインのユーザーにはproviderを"email"に設定（必要に応じて）
    User.where(provider: "").update_all(provider: "email")
    # uidはidを文字列として設定（例）
    User.where(uid: "").update_all("uid = id::text")

    # カラムの制約を変更
    change_column :users, :provider, :string, null: false, default: ""
    change_column :users, :uid, :string, null: false, default: ""
  end

  def down
    # ロールバック用：制約を元に戻す
    change_column :users, :provider, :string, null: true, default: nil
    change_column :users, :uid, :string, null: true, default: nil
  end
end
