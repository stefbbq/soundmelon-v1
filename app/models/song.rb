class Song < ActiveRecord::Base
  require 'mp3info'
  acts_as_votable
  belongs_to :user
  belongs_to :song_album
  has_many :posts
  has_many :playlists

  scope :processed, :conditions =>["is_processed = ?", true]
  scope :featured, :conditions =>["is_featured = ?", true]

  has_attached_file :song,
    :url => "/assets/bands/song/album/:id/:style/:normalized_attachment_file_name"

  #  validates_attachment_content_type :song,
  # :content_type => [ 'audio/mpeg', 'audio/x-mpeg', 'audio/mp3', 'audio/x-mp3', 'audio/mpeg3', 'audio/x-mpeg3', 'audio/mpg', 'audio/x-mpg', 'audio/x-mpegaudio', 'application/octet-stream']

  validates_attachment_size :song, :less_than => 15.megabytes
  validates_attachment_presence :song

  after_destroy :decrease_song_count
  after_create :increase_song_count,:set_default_title, :queue_song_for_processing

  Paperclip.interpolates :normalized_attachment_file_name do |attachment, style|
    attachment.instance.normalized_attachment_file_name
  end

  def normalized_attachment_file_name
    "#{self.song_file_name.gsub( /[^a-zA-Z0-9_\.]/, '_')}"
  end

  def get_default_title
    default_title = self.song_name_without_extension
    default_title
  end

  def set_default_title
    default_title = self.get_default_title
    self.update_attribute(:title, default_title)
  end

  def song_name_without_extension
    self.song_file_name.gsub(/\..*/,'')
  end

  def title_with_ext
    title = self.title.blank? ? "song_#{self.id}" : self.title
    "#{title.gsub(' ','_').gsub('.','')}#{File.extname(self.song.path)}"
  end

  # returns the song details with string formatted as necessary
  def song_detail
    song_title                      = self.title || self.get_default_title
    song_album                      = self.song_album(:include =>:band)
    song_album_name                 = song_album ? song_album.album_name : ''
    song_album_band                 = song_album ? song_album.band : nil
    song_album_band_name            = song_album_band ? song_album_band.name : ''
    mp3_song                        = self.song_mp3
    ogg_song                        = self.song_ogg    
    ogg_song_name_formatted         = ogg_song.gsub("'", "\\\\'")
    song_title_formatted            = song_title.gsub("'", "\\\\'")
    song_album_name_formatted       = song_album_name.gsub("'", "\\\\'")
    song_album_band_name_formatted  = song_album_band_name.gsub("'", "\\\\'")
    
    detail      = {
                  :id                   => self.id,
                  :mp3_song             => mp3_song,
                  :ogg_song             => ogg_song_name_formatted,      
                  :song_title           => song_title_formatted,
                  :song_album_name      => song_album_name_formatted,
                  :song_album_band_name => song_album_band_name_formatted,
                  :song_album           => song_album
                  }   
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

  # updates database by reading from the file
  def update_metadata_from_file
    # get meta-data from file itself
    song_file      = self.song.path
    song_title     = ''
    song_artist    = ''
    song_album     = ''
    song_track     = ''
    song_genre     = ''
    Mp3Info.open(song_file) { |mp3|
      song_title   = mp3.tag.title
      song_artist  = mp3.tag.artist
      song_album   = mp3.tag.album
      song_track   = mp3.tag.tracknum
      song_genre   = mp3.tag.genre
    }
    song_title     = song_title.blank? ? self.title : song_title
#    self.update_attributes(:title =>song_title, :artist =>song_artist, :album =>song_album, :track =>song_track, :genre =>song_genre)
    self.update_attributes(:artist =>song_artist, :album =>song_album, :track =>song_track, :genre =>song_genre)
  end

  # updates file itself from the db record
  def update_metadata_to_file
    # update meta-data from database
    song_file = self.song.path
    title     = self.title
    artist    = self.artist
    album     = self.album
    track     = self.track
    genre     = self.genre
    Mp3Info.open(song_file) { |mp3|
      mp3.tag.title     = title unless title.blank?
      mp3.tag.artist    = artist unless artist.blank?
      mp3.tag.album     = album unless album.blank?
      mp3.tag.tracknum  = track unless track.blank?
      mp3.tag.genre     = genre unless genre.blank?
    }
  end

  def queue_song_for_processing
    # push the song into the processing job queue
    self.delay.convert_song
    # first read from the file
    self.delay.update_metadata_from_file
#    # then update to the file read from the file
    self.delay.update_metadata_to_file
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
