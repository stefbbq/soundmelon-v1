class AddMentionItemToMentionedPosts < ActiveRecord::Migration
  def change
    add_column :mentioned_posts, :mentionitem_type, :string
    add_column :mentioned_posts, :mentionitem_id, :integer
    add_column :mentioned_posts, :mentionitem_name, :string
  end
end
