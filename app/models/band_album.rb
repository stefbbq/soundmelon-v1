class BandAlbum < ActiveRecord::Base
  acts_as_votable
  belongs_to :user
  belongs_to :band
  has_many :band_photos
  
  scope :published, :conditions =>["disabled = ?", false]

  def choose_cover_image band_photo = self.band_photos.first
    band_photo.update_attribute(:is_cover_image, true) if band_photo
  end

end
