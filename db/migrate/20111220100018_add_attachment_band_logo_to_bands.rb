class AddAttachmentBandLogoToBands < ActiveRecord::Migration
  def self.up
    add_column :bands, :logo_file_name, :string
    add_column :bands, :logo_content_type, :string
    add_column :bands, :logo_file_size, :integer
    add_column :bands, :logo_updated_at, :datetime
    add_column :bands, :bio, :text
    add_column :bands, :location, :string
    add_column :bands, :band_logo_url, :string
    add_column :bands, :website, :string
  end

  def self.down
    remove_column :bands, :logo_file_name
    remove_column :bands, :logo_content_type
    remove_column :bands, :logo_file_size
    remove_column :bands, :logo_updated_at
    remove_column :bands, :bio
    remove_column :bands, :location
    remove_column :band_logo_url
    remove_column :website
  end
end
