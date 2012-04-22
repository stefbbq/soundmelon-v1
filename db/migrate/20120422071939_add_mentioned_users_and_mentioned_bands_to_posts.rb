class AddMentionedUsersAndMentionedBandsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :mentioned_users, :string
    add_column :posts, :mentioned_user_ids, :string
    add_column :posts, :mentioned_bands, :string
    add_column :posts, :mentioned_band_ids, :string
  end
end
