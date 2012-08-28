class CreateFavoriteItems < ActiveRecord::Migration
  def change
    create_table :favorite_items do |t|
      t.string :item_type
      t.integer :item_id
      t.string :favoreditem_type
      t.integer :favoreditem_id

      t.timestamps
    end
  end
end
