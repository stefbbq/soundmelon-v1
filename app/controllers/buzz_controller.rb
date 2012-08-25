class BuzzController < ApplicationController
  before_filter :require_login
  before_filter :set_current_actor
  
  def artist_music_buzz
    @status                   = true
    if request.xhr?
      begin
        @artist_music         = ArtistMusic.find(params[:id])
        @buzzes               = Post.posts_for @artist_music
        @buzzes_by_dates      = @buzzes.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      rescue =>exp
        logger.error "Error in Buzz#AlbumBuzz :=> #{exp.message}"
        @status               = false
      end
    else
      redirect_to root_url and return
    end
  end
 
  def song_buzz
    @status                   = true
    if request.xhr?
      begin
        @song                 = Song.where(:id =>params[:id]).includes(:artist_music).first
        @buzzes               = Post.posts_for @song
        @buzzes_by_dates      = @buzzes.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      rescue =>exp
        logger.error "Error in Buzz::SongBuz :=> #{exp.message}"
        @status               = false
      end
    else
      redirect_to root_url and return
    end
  end

  def photo_album_buzz
    @status                   = true
    if request.xhr?
      begin
        @artist_photo_album   = Album.find(params[:id])
        @photo_album_buzzes   = Post.posts_for@artist_photo_album
        @buzzes_by_dates      = @photo_album_buzzes.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      rescue =>exp
        logger.error "Error in Buzz#PhotoAlbumBuzz :=> #{exp.message}"
        @status               = false
      end
    else
      redirect_to root_url and return
    end
  end

  def artist_show_buzz
    @status                   = true
    if request.xhr?
      begin
        @artist_show          = ArtistShow.find(params[:id])
        @artist_show_buzzes   = Post.posts_for @artist_show
        @buzzes_by_dates      = @artist_show_buzzes.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      rescue =>exp
        logger.error "Error in Buzz::ArtistShowBuzz :=> #{exp.message}"
        @status               = false
      end
    else
      redirect_to root_url and return
    end
  end

  # creates song album post as buzz
  def artist_music_buzz_post
    @status                   = true
    if request.xhr?
      begin
        @artist_music         = ArtistMusic.find params[:id]
        @buzz                 = Post.create_post_for @artist_music, @user, @actor, params
      rescue =>exp
        logger.error "Error in Buzz#AlbumBuzzPost :=> #{exp.message}"
        @status               = false
      end
      render :template  =>"/buzz/buzz_post" and return
    else
      redirect_to root_url and return
    end
  end

  # creates song post as buzz
  def song_buzz_post
    @status                   = true
    if request.xhr?
      begin
        @song                 = Song.find params[:id]
        @buzz                 = Post.create_post_for @song, @user, @actor, params
      rescue =>exp
        logger.error "Error in Buzz#SongBuzzPost :=> #{exp.message}"
        @status               = false
      end
      render :template  =>"/buzz/buzz_post" and return
    else
      redirect_to root_url and return
    end   
  end

  # creates photo album post as buzz
  def photo_album_buzz_post
    @status                   = true
    if request.xhr?
      begin
        @artist_album         = Album.find params[:id]
        @buzz                 = Post.create_post_for @artist_album, @user, @actor, params
      rescue =>exp
        logger.error "Error in Buzz::PhotoAlbumBuzzPost :=> #{exp.message}"
        @status               = false
      end
      render :template  =>"/buzz/buzz_post" and return
    else
      redirect_to root_url and return
    end
  end

  # creates photo post as buzz
  def photo_buzz_post
    @status                   = true
    if request.xhr?
      begin        
        @artist_photo         = Photo.find params[:id]
        @buzz                 = Post.create_post_for @artist_photo, @user, @actor, params
      rescue =>exp
        logger.error "Error in Buzz::ArtistPhotoBuzz :=>#{exp.message}"
        @status               = false
      end
      render :template  =>"/buzz/buzz_post" and return
    else
      redirect_to root_url and return
    end
  end

  # creates artist show post as buzz
  def artist_show_buzz_post
    @status                   = true
    if request.xhr?
      begin        
        @artist_show          = ArtistShow.find params[:id]
        @buzz                 = Post.create_post_for @artist_show, @user, @actor, params
      rescue =>exp
        logger.error "Error in Buzz::ArtistShowBuzz :=>#{exp.message}"
        @status               = false
      end
      render :template =>"/buzz/buzz_post" and return
    else
      redirect_to root_url and return
    end
  end

  private

  # sets who is creating the post
  def set_current_actor
    @actor         = current_actor
    @user          = current_user
  end
  
end
