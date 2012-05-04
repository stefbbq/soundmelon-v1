class ArtistController < ApplicationController
  before_filter :require_login
  
  def index
    begin
      @band = Band.where(:name => params[:band_name]).includes(:band_members).first
      if @is_admin_of_band         = current_user.is_admin_of_band?(@band)
        @band_members_count        = @band.band_members.count
        @other_bands               = current_user.admin_bands_except(@band)
        @posts                     = @band.find_own_as_well_as_mentioned_posts(params[:page])
        @bulletins                 = @band.bulletins
        @posts_order_by_dates      = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
        bulletin_next_page         = @bulletins.next_page
        @load_more_bulletins_path  = bulletin_next_page ? band_more_bulletins_path(:band_name => @band.name, :page => bulletin_next_page) : nil
        next_page                  = @posts.next_page
        @load_more_path            =  next_page ? band_more_posts_path(:band_name => @band.name, :page => next_page, :type => 'latest') : nil
        @unread_mentioned_count    = @band.unread_mentioned_post_count
        @unread_post_replies_count = @band.unread_post_replies_count
        @unread_messages_count     = @band.received_messages.unread.count
        @song_albums               = @band.limited_song_albums
        @photo_albums              = @band.limited_band_albums
        @band_artists              = @band.limited_band_members
        @band_fans_count           = @band.followers_count
        @band_fans                 = @band.limited_band_follower
        @band_tours                = @band.limited_band_tours
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to adminster band with band id: #{@band.id} which he is not a admin" 
        redirect_to fan_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end
  end
  
  def new
    @band = Band.new
  end
  
  def pull
    if request.xhr?
      @bands = current_user.bands.includes(:song_albums, :songs)
    else
      redirect_to root_url and return
    end
  end
  
  def create
    @band     = current_user.bands.build(params[:band])
    band_user = current_user.band_users.new
    if @band.save
      band_user.band_id       = @band.id
      band_user.access_level  = 1
      band_user.save
      @bands                  = current_user.bands
      render :action => 'index', :format => 'js' and return
    else
      render :action => 'new' and return
    end
  end
  
  def edit
    if request.xhr?
      begin
        @band = Band.where(:name => params[:band_name]).first
        if current_user.is_admin_of_band?(@band)          
          respond_to do |format|
            format.js
          end
        else
          logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to edit band with band id: #{@band.id} which he is not a admin" 
          render :nothing => true and return
        end
      rescue
        render :nothing   => true and return
      end
    else
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end    
  end
  
  def update
    @band     = Band.find(params[:id])
    if current_user.is_admin_of_band?(@band)
      if @band.update_attributes(params[:band])
        respond_to do |format|
          format.js
        end
      else
        respond_to do |format|
          format.js {render :action => 'edit' and return}
        end
      end
    else
      logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to update band with band id: #{@band.id} which he is not a admin" 
      render :nothing => true and return
    end    
  end
  
  def show
    @band               = Band.where(:name => params[:band_name]).includes(:band_members).first
    @band_members_count = @band.band_members.count
    @is_admin_of_band   = current_user.is_admin_of_band?(@band)
  end   
  
  def invite_bandmates
    redirect_to show_band_url(:band_name => params[:band_name]) and return unless request.xhr?
    begin
      @band      = Band.where(:name => params[:band_name]).first
      if current_user.is_admin_of_band?(@band)
        1.times { @band.band_invitations.new}
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to invite bandmate for a band with band id: #{@band.id} which he is not a admin" 
        redirect_to fan_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def send_bandmates_invitation    
    begin
      @band = Band.where(:name => params[:band_name]).first
      if current_user.is_admin_of_band?(@band)
        params['band']['band_invitations_attributes'].each do |key, value|
          value['user_id'] = current_user.id unless value.has_key?('id') 
        end
        if @band.update_attributes(params[:band])
          @msg = 'Invitation Send Successfully'
        end 
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to send invitation for bandmates to join a band with band id: #{@band.id} which he is not a admin" 
        redirect_to fan_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end
  end
  respond_to do |format|
    format.js {render :action => 'invite_bandmates' and return}
  end   
  
end