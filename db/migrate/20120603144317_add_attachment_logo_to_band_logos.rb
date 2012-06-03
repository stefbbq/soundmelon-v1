class AddAttachmentLogoToBandLogos < ActiveRecord::Migration
  def self.up
    add_column :band_logos, :logo_file_name, :string
    add_column :band_logos, :logo_content_type, :string
    add_column :band_logos, :logo_file_size, :integer
    add_column :band_logos, :logo_updated_at, :datetime
  end

  def self.down
    remove_column :band_logos, :logo_file_name
    remove_column :band_logos, :logo_content_type
    remove_column :band_logos, :logo_file_size
    remove_column :band_logos, :logo_updated_at
  end
end
