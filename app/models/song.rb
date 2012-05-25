class Song < ActiveRecord::Base
  require 'mp3info'
  acts_as_votable
  belongs_to :user
  belongs_to :song_album
  has_many :posts
  has_many :playlists

  scope :processed, :conditions =>["is_processed = ?", true]

  has_attached_file :song,    
    :url => "/assets/bands/song/album/:id/:style/:normalized_attachment_file_name"

  #  validates_attachment_content_type :song,
  # :content_type => [ 'audio/mpeg', 'audio/x-mpeg', 'audio/mp3', 'audio/x-mp3', 'audio/mpeg3', 'audio/x-mpeg3', 'audio/mpg', 'audio/x-mpg', 'audio/x-mpegaudio', 'application/octet-stream']

  #  after_post_process :queue_song_for_processing

  def queue_song_for_processing
    # push the song into the processing job queue    
    self.delay.convert_song
    self.delay.update_metadata_from_file
    self.delay.update_metadata_to_file
  end
  
  validates_attachment_size :song, :less_than => 15.megabytes
  validates_attachment_presence :song

  after_destroy :decrease_song_count
  after_create :increase_song_count, :queue_song_for_processing

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
    detail      = {:name =>self.song_name_without_extension}
    song_album  = self.song_album(:include =>:band)
    if song_album
      detail.update(:album =>song_album.album_name, :band =>song_album.band.name, :band_image =>'')
    else
      detail.update(:album =>'', :band=>'', :band_image =>'')
    end
    detail
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

  def song_mp3
    self.song
  end

  def song_ogg
    base_file_path  = self.song.url.split('/')
    base_file_path.pop
    ogg_file_url    = (base_file_path + ["#{self.file_name}.ogg"]).join('/')
    ogg_file_url
  end

  def convert_song enforced = false
    song_file               = self.song.path
    song_file_name          = self.song_file_name
    song_file_name_base     = song_file_name.split(File.extname(song_file_name)).first
    new_file_name_mp3       = [song_file_name_base, '.mp3'].join
    new_file_name_ogg       = [song_file_name_base, '.ogg'].join    
    if File.exists?(song_file)
      file_location         = song_file.split('/')
      file_location.pop
      new_file_location_mp3 = (file_location + [new_file_name_mp3]).join('/')
      new_file_location_ogg = (file_location + [new_file_name_ogg]).join('/')
      ffmpeg_command_mp3    = "ffmpeg -i " + song_file + " -y " + new_file_location_mp3
      ffmpeg_command_ogg    = "ffmpeg -i " + song_file + " -y " + new_file_location_ogg
      if enforced
        system(ffmpeg_command_mp3)
        system(ffmpeg_command_ogg)
      else
        logger.info "Already converted!"
        system(ffmpeg_command_mp3) unless File.exists?(new_file_location_mp3)
        system(ffmpeg_command_ogg) unless File.exists?(new_file_location_ogg)
      end      
      if File.exists?(new_file_location_mp3) && File.exists?(new_file_location_ogg)
        # delete original file
        #        File.delete song_file
        self.update_attributes(:song_file_name =>new_file_name_mp3,:file_name =>song_file_name_base, :is_processed =>true)
      end
    end
  end

  def update_metadata_from_file
    # get meta-data from file itself    
    song_file = self.song.path
    title     = ''
    artist    = ''
    album     = ''
    track     = ''
    genre     = ''
    Mp3Info.open(song_file) { |mp3|
      title   = mp3.tag.title
      artist  = mp3.tag.artist
      album   = mp3.tag.album
      track   = mp3.tag.tracknum
      genre   = mp3.tag.genre
    }
    self.update_attributes(:title =>title, :artist =>artist, :album =>album, :track =>track, :genre =>genre)
  end

  def update_metadata_to_file
    # update meta-data from database
    detail    = self.song_detail
    song_file = self.song.path
    title     = self.title
    artist    = self.artist
    album     = self.album
    track     = self.track
    genre     = self.genre
    Mp3Info.open(song_file) { |mp3|
      mp3.tag.title     = title || detail[:name]
      mp3.tag.artist    = artist || detail[:band]
      mp3.tag.album     = album || detail[:album]
      mp3.tag.tracknum  = track
      mp3.tag.genre     = genre
    }    
  end

  private

  def increase_song_count
    song_album = self.song_album    
    song_album.increment!(:song_count) if song_album
  end

  def decrease_song_count
    song_album = self.song_album    
    self.song_album.decrement!(:song_count) if song_album
  end

  # Fix the mime types. Make sure to require the mime-types gem
  def swfupload_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    self.file = data
  end

end
