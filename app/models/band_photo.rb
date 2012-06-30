class BandPhoto < ActiveRecord::Base
  belongs_to :band_album
  belongs_to :user

  has_many  :posts, :as =>:postitem, :dependent => :destroy
  
  after_destroy :decrease_photo_count
  after_create :create_newsfeed

  has_attached_file :image,
    :path => ":rails_root/public/sm/artist/photos/:normalized_file_name.:extension",
    :url => "/sm/artist/photos/:normalized_file_name.:extension",    
    :styles => { 
      :large  => ["800x800>", :jpeg],
      :medium => ["300x300>", :jpeg],
      :thumb  => ["35x35#", :jpeg]
    }  
      
#  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/jpg']
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_presence :image

  Paperclip.interpolates :normalized_file_name do |attachment, style|
    attachment.instance.normalized_file_name(style)
  end

  def normalized_file_name style
    name = "#{style}-#{self.id}"
    "#{Digest::SHA1.hexdigest(name)}"
  end
  
  def decrease_photo_count
    album = self.band_album
    self.band_album.decrement!(:photo_count) if album
  end

  # Fix the mime types. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    self.file = data
  end

  def create_newsfeed
    Post.create_newsfeed_for self, nil, self.band_album.band_id, " created"
  end

  def artist
    self.band_album.band
  end

end
