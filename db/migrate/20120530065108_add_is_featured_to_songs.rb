class AddIsFeaturedToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :is_featured, :boolean, :default =>false
  end
end
