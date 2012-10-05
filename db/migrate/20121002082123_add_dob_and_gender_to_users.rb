class AddDobAndGenderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dob, :date
    add_column :users, :gender, :boolean,          :default => true
  end
end
