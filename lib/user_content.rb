# all contents like fan photos; artist photos, musics; venue photos
module UserContent

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods    
  end

  def root_content
    object_type = self.class.name
    case object_type
    when 'Song'
      self.artist_music
    when 'ArtistMusic'
      self
    when 'Photo'
      self.album
    when 'Album'
      self
    when 'ArtistShow'
      self
    end
  end
  
end