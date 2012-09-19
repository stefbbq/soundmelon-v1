class AddProfileItemsToProfilePics < ActiveRecord::Migration
  def change
    add_column :profile_pics, :profileitem_type, :string
    add_column :profile_pics, :profileitem_id, :integer
    ProfilePic.all.each do |pp|
      pp.update_attributes(:profileitem_type =>'User', :profileitem_id =>pp.id)
    end
    remove_column :profile_pics, :user_id
  end
end
