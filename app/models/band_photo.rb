class BandPhoto < ActiveRecord::Base
  belongs_to :band_album
  belongs_to :user
  
  has_attached_file :image, 
    :url => "/assets/bands/album/:id/:style/:basename.:extension",
    :styles => { 
      :large => "800x800>", 
      :medium => "300x300>", 
      :thumb => "35x35#"
    }
      
  #validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/jpg'] 
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_presence :image
  
  # Fix the mime types. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    self.file = data
  end
end
