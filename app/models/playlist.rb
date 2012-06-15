class Playlist < ActiveRecord::Base
  belongs_to :user
  belongs_to :song
  
  validates :user_id, :uniqueness => {:scope => :song_id} 
  
  def self.add_song_for(user_id, song_id)
    Playlist.find_or_create_by_user_id_and_song_id(user_id, song_id)
  end
  
  def self.remove_song_for(user_id, song_id)
    playlist = Playlist.where(:user_id => user_id, :song_id => song_id).first
    if playlist
      playlist.destroy!
    else
      raise 'RecordNotFoundException'
    end
  end
  
  def self.add_whole_album_songs_for(user_id, song_album)
    song_album.songs.each do |song|
      Playlist.find_or_create_by_user_id_and_song_id(user_id, song.id)
    end
  end
  
end
