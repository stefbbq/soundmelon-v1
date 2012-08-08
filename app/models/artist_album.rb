class ArtistAlbum < ActiveRecord::Base
  acts_as_votable
  belongs_to :user
  belongs_to :artist, :foreign_key =>'artist_id', :class_name =>'Artist'
  has_many :artist_photos, :after_add => :set_cover_image, :dependent =>:destroy
  belongs_to :cover_image, :class_name =>'ArtistPhoto'

  has_many  :posts, :as =>:postitem, :dependent => :destroy

  after_create :create_newsfeed

  scope :published, :conditions =>["disabled = ?", false]

  def choose_cover_image artist_photo = self.artist_photos.first
    if  artist_photo
      self.cover_image = artist_photo
      self.save
    end
  end

  def set_cover_image artist_photo
    self.increment!(:photo_count)
    begin
      set_the_cover_image artist_photo, self.cover_image.blank?
    rescue =>exp
      logger.error "Error in ArtistAlbum::SetCoverImage :#{exp.message}"
    end
  end

  def set_the_cover_image artist_photo, overwrite = false
    if overwrite
      self.cover_image = artist_photo
    else
      self.cover_image = artist_photo unless self.cover_image
    end
    self.save
  end

  def create_newsfeed
    Post.create_newsfeed_for self, nil, self.artist_id, " created"
  end

  def to_param
    self.name
  end
  
end
