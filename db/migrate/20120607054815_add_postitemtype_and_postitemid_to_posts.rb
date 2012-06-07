class AddPostitemtypeAndPostitemidToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :postitem_type, :string
    add_column :posts, :postitem_id, :integer
    remove_column :posts, :song_album_id
    remove_column :posts, :song_id
  end
end
