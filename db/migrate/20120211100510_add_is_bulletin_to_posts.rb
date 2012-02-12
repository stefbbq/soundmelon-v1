class AddIsBulletinToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :is_bulletin, :boolean, :default => false
  end
end
