class Song < ActiveRecord::Base
  acts_as_votable
  belongs_to :user
  belongs_to :song_album
  has_many :posts
  has_many :playlists
  
  has_attached_file :song, 
    :url => "/assets/bands/song/album/:id/:style/:normalized_attachment_file_name"
  
#  validates_attachment_content_type :song,
#    :content_type => [ 'audio/mpeg', 'audio/x-mpeg', 'audio/mp3', 'audio/x-mp3', 'audio/mpeg3', 'audio/x-mpeg3', 'audio/mpg', 'audio/x-mpg', 'audio/x-mpegaudio', 'application/octet-stream' ]
     
  validates_attachment_size :song, :less_than => 15.megabytes
  validates_attachment_presence :song 
  
  after_destroy :decrease_song_count
  after_create :increase_song_count


  Paperclip.interpolates :normalized_attachment_file_name do |attachment, style|
    attachment.instance.normalized_attachment_file_name
  end
  
  def normalized_attachment_file_name
    "#{self.song_file_name.gsub( /[^a-zA-Z0-9_\.]/, '_')}"
  end
  
  def song_name_without_extension
    self.song_file_name.gsub(/\..*/,'')
  end

  def song_detail
    detail      = {}
    song_album  = self.song_album(:include =>:band)    
    song_album ? {:album =>song_album.album_name, :band =>song_album.band.name, :band_image =>''} : {:album =>'', :band=>'', :band_image =>''}
  end

  def do_like_by user
    song_album      = self.song_album(:include =>:band)
    band            = song_album.band
    genres          = band ? band.genre : []
    genres          = genres.blank? ? [] : genres.split(',').map{|g| Genre.find_by_name(g)}
    GenreUser.add_genre_and_users genres, user    
  end

  def do_dislike_by user
    song_album      = self.song_album(:include =>:band)
    band            = song_album.band
    genres          = band ? band.genre : []
    genres          = genres.blank? ? [] : genres.split(',').map{|g| Genre.find_by_name(g)}
    GenreUser.remove_genre_and_users genres, user    
  end

  private

  def increase_song_count
    self.song_album.increment! :song_count
  end

  def decrease_song_count
    self.song_album.decrement! :song_count
  end

  # Fix the mime types. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    self.file = data
  end
  
  
end
