class BandPhoto < ActiveRecord::Base
  belongs_to :band_album
  belongs_to :user
  
  after_destroy :decrease_photo_count
  after_create :increase_photo_count

  has_attached_file :image, 
    :url => "/assets/bands/album/:id/:style/:basename.:extension",
    :styles => { 
      :large  => ["800x800>", :jpeg],
      :medium => ["300x300>", :jpeg],
      :thumb  => ["35x35#", :jpeg]
    }  
      
#  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/jpg']
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_presence :image

  def increase_photo_count
    album = self.band_album
    album.increment!(:photo_count) if album
  end

  def decrease_photo_count
    album = self.band_album
    self.band_album.decrement!(:photo_count) if album
  end

  # Fix the mime types. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    self.file = data
  end
end
