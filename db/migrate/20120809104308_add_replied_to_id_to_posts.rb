class AddRepliedToIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :reply_to_id, :integer
  end
end
