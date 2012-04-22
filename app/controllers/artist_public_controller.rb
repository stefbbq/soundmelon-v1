class ArtistPublicController < ApplicationController
  before_filter :require_login

  def index
    begin
      @band                      = Band.where(:name => params[:band_name]).includes(:band_members).first
      @band_members_count        = @band.band_members.count      
      @posts                     = @band.find_own_as_well_as_mentioned_posts(params[:page])
      @bulletins                 = @band.bulletins
      @posts_order_by_dates      = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      bulletin_next_page         = @bulletins.next_page
      @load_more_bulletins_path  = bulletin_next_page ? band_more_bulletins_path(:band_name => @band.name, :page => bulletin_next_page) : nil
      next_page                  = @posts.next_page
      @load_more_path            =  next_page ? band_more_posts_path(:band_name => @band.name, :page => next_page, :type => 'latest') : nil
      unless request.xhr?
        @song_albums             = @band.limited_song_albums
        @photo_albums            = @band.limited_band_albums
        @band_artists            = @band.limited_band_members
        @band_fans_count         = @band.followers_count
        @band_fans               = @band.limited_band_follower
      end
    rescue
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end
  end

  def members
    if request.xhr?
      begin
        @band         = Band.where(:name => params[:band_name]).includes(:band_members).first
        @band_members = @band.band_members
        respond_to do |format|
          format.js
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(:band_name => params[:band_name]) and return
    end
  end

  def social
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
    @song_albums                = @band.limited_song_albums
    @photo_albums               = @band.limited_band_albums
    @band_artists               = @band.limited_band_members
    @band_fans_count            = @band.followers_count
    @band_fans                  = @band.limited_band_follower
    @band_tours                 = [] #
  end

  def store
    if request.xhr?
      @band       = Band.where(:name => params[:band_name]).includes(:band_members).first
    else
      redirect_to root_url and return
    end
  end


  def follow_band
    if request.xhr?
      begin
        @band = Band.where(:name => params[:band_name]).first
        current_user.follow(@band)  unless current_user.following?(@band)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(:band_name => params[:band_name]) and return
    end
  end

  def unfollow_band
    if request.xhr?
      begin
        @band = Band.where(:name => params[:band_name]).first
        current_user.stop_following(@band)  if current_user.following?(@band)
      rescue
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(:band_name => params[:band_name]) and return
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
        @band = Band.find(params[:id])
        @message = ActsAsMessageable::Message.new
      rescue
        render :nothing => true and return
      end
    else
      redirect_to root_url and return
    end
  end

  def fans
    if request.xhr?
      band        = Band.where(:name => params[:band_name]).first
      @band_fans  = band.user_followers
    else
      redirect_to show_band_url(:band_name => params[:band_name])
    end
  end

end
