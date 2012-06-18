class AddUserAccountTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_account_type, :string
  end
end
