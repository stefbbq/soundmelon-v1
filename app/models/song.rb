class Song < ActiveRecord::Base
  belongs_to :user
  belongs_to :song_album
    
  has_attached_file :song, 
    :url => "/assets/bands/song/album/:id/:style/:normalized_attachment_file_name"
      
  #validates_attachment_content_type :image, :content_type => ['audio/mp4', 'audio/m4v', 'audio/f4v', 'audio/mov', '[audio/mpeg]','audio/mpeg', 'audio/mp3'] 
  validates_attachment_size :song, :less_than => 15.megabytes
  validates_attachment_presence :song 
  
  Paperclip.interpolates :normalized_attachment_file_name do |attachment, style|
    attachment.instance.normalized_attachment_file_name
  end
  
  def normalized_attachment_file_name
    "#{self.song_file_name.gsub( /[^a-zA-Z0-9_\.]/, '_')}"
  end
  
  private
  
  # Fix the mime types. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    self.file = data
  end
  
  
end
