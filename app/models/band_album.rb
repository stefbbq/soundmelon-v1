class BandAlbum < ActiveRecord::Base
  belongs_to :user
  belongs_to :band
  has_many :band_photos
end
