class Album < ActiveRecord::Base
  include UserContent
  
  belongs_to :user
  belongs_to :useritem, :polymorphic =>true
  has_many :photos, :after_add => :set_cover_image, :dependent =>:destroy
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

  def newsfeed
    self.posts.where("is_newsfeed is true")
  end

  def disable
    self.update_attribute(:disabled, true)
    newsfeeds = self.newsfeed
    newsfeeds.each{|p| p.update_attribute(:is_deleted, true)}
  end

  def enable
    self.update_attribute(:disabled, false)
    newsfeeds = self.newsfeed
    newsfeeds.each{|p| p.update_attribute(:is_deleted, false)}
  end
  
  def to_param
    self.id
  end
  
end
