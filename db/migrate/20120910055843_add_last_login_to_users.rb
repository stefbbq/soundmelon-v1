class AddLastLoginToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_artist_login_at, :datetime
    add_column :users, :last_venue_login_at, :datetime
  end
end
