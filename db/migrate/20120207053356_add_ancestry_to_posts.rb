class AddAncestryToPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :parent_id
    add_column :posts, :ancestry, :string
    add_index :posts, :ancestry 
  end
end
