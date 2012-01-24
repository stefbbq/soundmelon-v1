class AddUserNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mention_name, :string
  end
end
