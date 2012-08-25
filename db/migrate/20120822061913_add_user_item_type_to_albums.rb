class AddUserItemTypeToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :useritem_type, :string
    add_column :albums, :useritem_id, :integer
    add_column :albums, :photo_count, :integer,   :default => 0
    add_column :albums, :disabled,     :boolean,  :default => false
    add_column :albums, :cover_image_id, :integer
  end
end
