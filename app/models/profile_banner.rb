class ProfileBanner < ActiveRecord::Base
  belongs_to :profileitem, :polymorphic =>true

  scope :current_for, lambda{|item| where('profileitem_type = ? and profileitem_id = ? and is_current is true', item.class.name, item.id)}

  has_attached_file :image,
    :styles     => {          
          :large    => ['963x320#',:jpg],
          :medium   => ['300x300#', :jpg]
        },
    :path => ":rails_root/public/sm/banners/:normalized_file_name.:extension",
    :url => "/sm/banners/:normalized_file_name.:extension",
    :processors => [:banner_cropper]
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/jpg']
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_presence :image

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :reprocess_banner_image, :if => :cropping?

  Paperclip.interpolates :normalized_file_name do |attachment, style|
    attachment.instance.normalized_file_name(style)
  end

  def normalized_file_name style
    name = "#{style}-#{self.id}"
    "#{Digest::SHA1.hexdigest(name)}"
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def image_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(image.path(style))
  end

  private

  def reprocess_banner_image
    image.reprocess!
  end

end
