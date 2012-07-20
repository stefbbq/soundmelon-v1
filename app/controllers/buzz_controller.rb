class BuzzController < ApplicationController
  before_filter :require_login
  before_filter :set_current_actor, :only =>[:album_buzz_post , :song_buzz_post, :band_album_buzz_post, :photo_buzz_post, :artist_show_buzz_post ]
  
  def album_buzz
    if request.xhr?
      begin
        @song_album       = SongAlbum.find(params[:id])
        @buzzes           = Post.posts_for @song_album
        @buzzes_by_dates  = @buzzes.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      rescue =>exp
        logger.error "Error in Buzz#AlbumBuzz :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end
 
  def song_buzz 
    if request.xhr?
      begin
        @song                 = Song.where(:id =>params[:id]).includes(:song_album).first
        @buzzes               = Post.posts_for @song
        @buzzes_by_dates      = @buzzes.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      rescue =>exp
        logger.error "Error i Buzz::SongBuz :=> #{exp.message}"
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
        @photo_album_buzzes   = Post.posts_for@band_photo_album
        @buzzes_by_dates      = @photo_album_buzzes.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      rescue =>exp
        logger.error "Error in Buzz#BandPhotoAlbumBuzz :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  def artist_show_buzz
    if request.xhr?
      begin
        @artist_show           = ArtistShow.find(params[:id])
        @artist_show_buzzes    = Post.posts_for @artist_show
        @buzzes_by_dates     = @artist_show_buzzes.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      rescue =>exp
        logger.error "Error in Buzz::ArtistShowBuzz :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  # creates song album post as buzz
  def album_buzz_post 
    if request.xhr?
      begin
        @song_album         = SongAlbum.find params[:id]        
        @buzz               = Post.create_post_for @song_album, @actor, params
      rescue =>exp
        logger.error "Error in Buzz#AlbumBuzzPost :=> #{exp.message}"
        render :nothing => true and return
      end
      render :template =>"/buzz/buzz_post" and return
    else
      redirect_to root_url and return
    end
  end

  # creates song post as buzz
  def song_buzz_post
    if request.xhr?
      begin
        @song               = Song.find params[:id]
        @buzz               = Post.create_post_for @song, @actor, params
      rescue
        render :nothing => true and return
      end
      render :template =>"/buzz/buzz_post" and return
    else
      redirect_to root_url and return
    end   
  end

  # creates band photo album post as buzz
  def band_album_buzz_post
    if request.xhr?
      begin
        @band_album         = BandAlbum.find params[:id]
        @buzz               = Post.create_post_for @band_album, @actor, params
      rescue =>exp
        logger.error "Error in Buzz::BandAlbumBuzzPost :=> #{exp.message}"
        render :nothing => true and return
      end
      render :template =>"/buzz/buzz_post" and return
    else
      redirect_to root_url and return
    end
  end

  # creates band photo post as buzz
  def photo_buzz_post
    if request.xhr?
      begin        
        @band_photo         = BandPhoto.find params[:id]
        @buzz               = Post.create_post_for @band_photo, @actor, params
      rescue
        render :nothing => true and return
      end
      render :template =>"/buzz/buzz_post" and return
    else
      redirect_to root_url and return
    end
  end

  # creates band tour post as buzz
  def artist_show_buzz_post
    if request.xhr?
      begin        
        @artist_show        = ArtistShow.find params[:id]
        @buzz               = Post.create_post_for @artist_show, @actor, params
      rescue
        render :nothing => true and return
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
  end
  
end
