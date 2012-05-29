class ArtistPublicController < ApplicationController
  before_filter :require_login

  def members    
    begin
      @band         = Band.where(:name => params[:band_name]).includes(:band_members).first
      @band_members = @band.band_members
      get_artist_objects_for_right_column(@band)
      respond_to do |format|
        format.js
        format.html
      end
    rescue => exp
      logger.error "Error in ArtistPublic#Members :=> #{exp.message}"
      render :template =>'/bricks/page_missing' and return
      render :nothing => true and return
    end
  end

  def social
    begin
      @band                       = Band.where(:name => params[:band_name]).includes(:band_members).first
      @is_admin_of_band           = current_user.is_admin_of_band?(@band)
      @band_members_count         = @band.band_members.count
      @posts                      = @band.find_own_posts(params[:page])
      @posts_order_by_dates       = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      @bulletins                  = @band.bulletins
      bulletin_next_page          = @bulletins.next_page
      @load_more_bulletins_path   = bulletin_next_page ? band_more_bulletins_path(:band_name => @band.name, :page => bulletin_next_page) : nil
      next_page                   = @posts.next_page
      @load_more_path             =  next_page ? band_more_posts_path(:band_name => @band.name, :page => next_page, :type => 'general') : nil
      @song_album_count           = @band.song_albums.size
      @photo_album_count          = @band.band_albums.size
      @tour_count                 = @band.band_tours.size
      @band_artist_count          = @band.band_members.size
      @band_fan_count             = @band.followers_count
      @song_albums                = @band.limited_song_albums
      @photo_albums               = @band.limited_band_albums
      @band_tours                 = @band.band_tours
      @band_artists               = @band.limited_band_members
      @band_fans                  = @band.limited_band_follower
    rescue  => exp
      logger.error "Error in ArtistPublic#Members :=> #{exp.message}"
      render :template =>'/bricks/page_missing' and return
    end
  end

  def store
    if request.xhr?
      @band       = Band.where(:name => params[:band_name]).includes(:band_members).first
    else
      redirect_to root_url and return
    end
  end

  def send_message
    if request.xhr?
      begin
        to_band = Band.find(params[:id])
        if current_user.send_message(to_band, :body => params[:body])
        else
          # though body is empty, let the bogus user feel msg is sent
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  def new_message
    if request.xhr?
      begin
        @band     = Band.find(params[:id])
        @message  = ActsAsMessageable::Message.new
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end
  
end
