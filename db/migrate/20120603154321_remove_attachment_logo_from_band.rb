class RemoveAttachmentLogoFromBand < ActiveRecord::Migration
  def up
    remove_column :bands, :logo_file_name
    remove_column :bands, :logo_content_type
    remove_column :bands, :logo_file_size
    remove_column :bands, :logo_updated_at
  end

  def down
    add_column :bands, :logo_file_name, :string
    add_column :bands, :logo_content_type, :string
    add_column :bands, :logo_file_size, :integer
    add_column :bands, :logo_updated_at, :datetime
  end
end
