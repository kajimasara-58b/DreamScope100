class AddLinkTokenToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :link_token, :string
    add_column :users, :link_token_sent_at, :datetime
  end
end
