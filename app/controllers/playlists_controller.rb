class PlaylistsController < ApplicationController
  before_filter :require_login
  before_filter :check_xhr_request
  
  def add
    begin
      @song         = Song.find(params[:id])
      Playlist.add_song_for(current_user.id, @song.id)
      @songs        = [@song]
    rescue =>exp
      logger.error "Error in Playlist::Add :=>#{exp.message}"
      render :nothing => 'true' and return
    end
  end
  
  def remove
    begin
      song          = Song.find(params[:id])
      Playlist.remove_song_for(current_user.id, song.id)
    rescue =>exp
      logger.error "Error in Playlist::Remove :=>#{exp.message}"
      render :nothing => 'true' and return
    end
  end
  
  def add_all_songs_of_album
    begin
      @artist_music = ArtistMusic.find(params[:id])
      Playlist.add_artist_music_songs_for(current_user.id, @artist_music)
      @songs        = @artist_music.songs
    rescue =>exp
      logger.error "Error in Playlist::AddAllSongsOfAlbum :=>#{exp.message}"
      render :nothing => 'true' and return
    end
  end

  def add_to_player_queue
    @artist_music   = ArtistMusic.where("id=?", params[:id]).includes(:songs).first
    @songs          = @artist_music.songs
  end
  
  private
  
  def check_xhr_request
    redirect_to root_url and return unless request.xhr?
  end
  
end
