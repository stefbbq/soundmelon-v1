class BandAlbum < ActiveRecord::Base
  acts_as_votable
  belongs_to :user
  belongs_to :band
  has_many :band_photos
  
  scope :published, :conditions =>["disabled = ?", false]
end
