class Album < ActiveRecord::Base
  belongs_to :user
  belongs_to :useritem, :polymorphic =>true
  has_many :photos
  has_many  :posts, :as =>:postitem, :dependent => :destroy  
  belongs_to :cover_image, :class_name =>'Photo'
  

  after_create :create_newsfeed

  scope :published, :conditions =>["disabled = ?", false]

  def choose_cover_image photo = self.photos.first
    if  photo
      self.cover_image = photo
      self.save
    end
  end

  def set_cover_image photo
    self.increment!(:photo_count)
    begin
      set_the_cover_image photo, self.cover_image.blank?
    rescue =>exp
      logger.error "Error in Album::SetCoverImage :#{exp.message}"
    end
  end

  def set_the_cover_image photo, overwrite = false
    if overwrite
      self.cover_image = photo
    else
      self.cover_image = photo unless self.cover_image
    end
    self.save
  end

  def create_newsfeed
    Post.create_newsfeed_for self, nil, self.useritem_type, self.useritem_id, " created"
  end

  def to_param
    self.name
  end
  
end
