class AddUseridToProfilePics < ActiveRecord::Migration
  def self.up
    add_column :profile_pics, :userid, :integer
  end

  def self.down
    remove_column :profile_pics, :userid
  end
end
