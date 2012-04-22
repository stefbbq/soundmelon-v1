class AddFacebookAndTwitterPageToBands < ActiveRecord::Migration
  def change
    add_column :bands, :facebook_page, :string
    add_column :bands, :twitter_page, :string
  end
end
