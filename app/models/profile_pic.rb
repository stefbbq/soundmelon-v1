class ProfilePic < ActiveRecord::Base
  belongs_to :user 
  has_attached_file :avatar, :styles => { :small => "50x50#", :medium => '100x100#', :large => "190x310>" }, :processors => [:cropper]
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png', 'image/jpg'] 
  validates_attachment_size :avatar, :less_than => 5.megabytes
  validates_attachment_presence :avatar
  
  attr_protected  :user_id
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :reprocess_avatar, :if => :cropping?
  
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end
  
  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end
  
  private
  
  def reprocess_avatar
    avatar.reprocess!
  end  
 
end
