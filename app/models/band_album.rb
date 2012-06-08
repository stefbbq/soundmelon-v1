class BandAlbum < ActiveRecord::Base
  acts_as_votable
  belongs_to :user
  belongs_to :band
  has_many :band_photos, :after_add => :set_cover_image
  belongs_to :cover_image, :class_name =>'BandPhoto'

  has_many  :posts, :as =>:postitem, :dependent => :destroy
  
  after_create :create_newsfeed

  scope :published, :conditions =>["disabled = ?", false]

  def choose_cover_image band_photo = self.band_photos.first
    if  band_photo
      self.cover_image = band_photo
      self.save
    end
  end
  
  def set_cover_image band_photo
    self.increment!(:photo_count)
    begin
      set_the_cover_image band_photo, self.cover_image.blank?
    rescue =>exp
      logger.error "Error in BandAlbum::SetCoverImage :#{exp.message}"
    end
  end

  def set_the_cover_image band_photo, overwrite = false
    if overwrite
      self.cover_image = band_photo
    else
      self.cover_image = band_photo unless self.cover_image
    end
    self.save
  end

  def create_newsfeed
    Post.create_newsfeed_for self, nil, self.band_id, " created"
  end

end
