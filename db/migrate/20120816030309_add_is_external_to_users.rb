class AddIsExternalToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_external, :boolean, :default =>false
    add_column :users, :oauth_id, :string
    add_column :users, :oauth_type, :string
    add_column :users, :oauth_token, :string
    add_column :users, :oauth_token_secret, :string
  end
end
