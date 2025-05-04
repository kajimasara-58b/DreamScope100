class AddIsDummyPasswordToUsers < ActiveRecord::Migration[7.2]
  def change
    # is_dummy_password カラムを追加（boolean、デフォルト: false、null 不可）
    add_column :users, :is_dummy_password, :boolean, default: false, null: false

    # 既存ユーザーの is_dummy_password を設定
    reversible do |dir|
      dir.up do
        # provider: "line" のユーザーは true、それ以外は false（デフォルト）
        User.where(provider: "line").update_all(is_dummy_password: true)
      end
    end
  end
end
