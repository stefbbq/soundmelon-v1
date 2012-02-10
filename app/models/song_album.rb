class SongAlbum < ActiveRecord::Base
  belongs_to :user
  belongs_to :band
  has_many :songs
  accepts_nested_attributes_for :songs, :reject_if => proc { |attributes| attributes['song'].blank?}
  
  has_attached_file :cover_img, 
    :styles => { :small => '50x50#', :medium => '100x100>', :large => '300x180#' },
    :url => "/assets/images/album/cover/image/:id/:style/:basename.:extension"
  
  validates_attachment_content_type :cover_img, :content_type => ['image/jpeg', 'image/png', 'image/jpg'] 
  validates_attachment_size :cover_img, :less_than => 5.megabytes
  
end