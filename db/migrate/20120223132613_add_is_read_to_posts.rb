class AddIsReadToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :is_read, :boolean, :default => 0
  end
end
