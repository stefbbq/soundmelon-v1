class AddUserItemTypeAndUserItemIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :useritem_type, :string
    add_column :posts, :useritem_id, :integer
  end
end
