class Photo < ActiveRecord::Base

  belongs_to :album
  belongs_to :user
  has_many  :posts, :as =>:postitem, :dependent => :destroy

  has_attached_file :image,
    :path => ":rails_root/public/sm/user/photos/:normalized_file_name.:extension",
    :url => "/sm/user/photos/:normalized_file_name.:extension",
    :styles => {
      :large  => ["800x800#", :jpeg],
      :medium => ["300x300#", :jpeg],
      :thumb  => ["35x35!", :jpeg]
    },
    :processors => [:resizer]
  
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/jpg', '[image/jpeg]', '[image/png]', '[image/jpg]']
  validates_attachment_size :image, :less_than => 3.megabytes
  validates_attachment_presence :image
   

  after_destroy :decrease_photo_count
  after_create :create_newsfeed

  Paperclip.interpolates :normalized_file_name do |attachment, style|
    attachment.instance.normalized_file_name(style)
  end

  def normalized_file_name style
    name = "#{style}-#{self.id}"
    "#{Digest::SHA1.hexdigest(name)}"
  end

  def decrease_photo_count
    album = self.album
    self.album.decrement!(:photo_count) if album && album.photo_count >0
  end

  # Fix the mime types. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    self.file = data
  end

  def create_newsfeed
    album             = self.album
    album_useritem    = album.useritem
#    Post.create_newsfeed_for self, nil, album_useritem.class.name, album_useritem.id, " created"
  end

  def useritem
    self.album.useritem
  end

  def reprocess
    self.image.reprocess!
  end
   
end
