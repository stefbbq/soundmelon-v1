class RemoveLnameConstraintFromUsers < ActiveRecord::Migration
  def change
    change_column(:users, :lname, :string)
  end

end
