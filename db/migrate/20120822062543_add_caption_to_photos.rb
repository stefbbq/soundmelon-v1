class AddCaptionToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :caption, :string
    add_column :photos, :user_id, :integer
  end
end
