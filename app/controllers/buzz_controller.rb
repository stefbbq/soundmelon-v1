class BuzzController < ApplicationController
  before_filter :require_login
  
  def album_buzz
    if request.xhr?
      begin
        @song_album       = SongAlbum.find(params[:id])
        @buzzes           = Post.album_buzz_for(@song_album.id)
        @buzzes_by_dates  = @buzzes.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
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
        @song     = Song.where(:id =>params[:id]).includes(:song_album).first
        @buzzes   = Post.song_buzz_for(@song.id)
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
        @buzzes_by_dates      = @photo_album_buzzes.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
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
        @buzz       = Post.create_song_album_buzz_by(current_user.id, params)
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
        @buzz       = Post.create_song_buzz_by(current_user.id, params)
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
        @buzz       = Post.create_photo_buzz_by(current_user.id, params)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  def band_tour_buzz
    if request.xhr?
      begin
        @band_tour           = BandTour.find(params[:id])
        @band_tour_buzzes    = TourPost.band_tour_buzz_for(@band_tour.id)
        @buzzes_by_dates     = @band_tour_buzzes.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  def band_tour_buzz_post
    if request.xhr?
      begin        
        @buzz       = TourPost.create_band_tour_buzz_by(current_user.id, params)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end
  
end
