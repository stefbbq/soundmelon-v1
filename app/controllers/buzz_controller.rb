class BuzzController < ApplicationController
  before_filter :require_login
  
  def album_buzz
    if request.xhr?
      begin
        @song_album = SongAlbum.find(params[:id])
        @buzzes     = Post.album_buzz_for(@song_album.id)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end
 
  def song_buzz 
    if request.xhr?
      begin
        @song = Song.find(params[:id])
        @buzzes = Post.song_buzz_for(@song.id)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  def band_photo_album_buzz
    if request.xhr?
      begin
        @band_photo_album     = BandAlbum.find(params[:id])
        @photo_album_buzzes   = PhotoPost.band_album_buzz_for(@band_photo_album.id)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

 
  def album_buzz_post 
    if request.xhr?
      begin
        @song_album = SongAlbum.find(params[:id])
        @buzz = Post.create_song_album_buzz_by(current_user.id, params)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end
 
  def song_buzz_post
    if request.xhr?
      begin
        @song_album = Song.find(params[:id])
        @buzz = Post.create_song_buzz_by(current_user.id, params)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end   
  end

  def band_album_buzz_post
    if request.xhr?
      begin
        @song_album = BandAlbum.find(params[:id])
        @buzz       = PhotoPost.create_band_album_buzz_by(current_user.id, params)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  def photo_buzz_post
    if request.xhr?
      begin
        @song_album = BandPhoto.find(params[:id])
        @buzz = Post.create_photo_buzz_by(current_user.id, params)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

end
