class BandsController < ApplicationController
  before_filter :require_login
  
  def index
    @bands = current_user.bands.includes(:song_albums, :songs)
  end
  
  def manage
    begin
      @band = Band.where(:name => params[:band_name]).includes(:band_members).first
      if current_user.is_admin_of_band?(@band)
         #@messages = @band.received_messages #.limit(DEFAULT_NO_OF_MESSAGE_DISPLAY)
         @band_members_count = @band.band_members.count
         @other_bands = current_user.admin_bands_except(@band)
         @posts = @band.find_own_as_well_as_mentioned_posts(params[:page])
         @bulletins = @band.bulletins
         @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}    
         next_page = @posts.next_page
         @load_more_path =  next_page ?  more_post_path(next_page) : nil
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to adminster band with band id: #{@band.id} which he is not a admin" 
        redirect_to user_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to user_home_url, :notice => 'Something went wrong! Try Again' and return
    end
  end
  
  def new
    @band = Band.new
  end
  
  def create
    @band = current_user.bands.build(params[:band])
    band_user = current_user.band_users.new

    if @band.save
      band_user.band_id = @band.id
      band_user.access_level = 1
      band_user.save
      @bands = current_user.bands
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
        render :nothing => true and return
      end
    else
      redirect_to user_home_url, :notice => 'Something went wrong! Try Again' and return
    end    
  end
  
  def update
    @band = Band.find(params[:id])
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
    @band = Band.where(:name => params[:band_name]).includes(:band_members).first
    @band_members_count = @band.band_members.count
    @is_admin_of_band = current_user.is_admin_of_band?(@band)
  end
  
  def social
    if request.xhr?
      @band = Band.where(:name => params[:band_name]).includes(:band_members).first
      @posts = @band.find_own_as_well_as_mentioned_posts(params[:page])
      @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}    
      next_page = @posts.next_page
      @load_more_path =  next_page ?  more_post_path(next_page) : nil
    else
      redirect_to root_url and return
    end
  end
  
  def store
    if request.xhr?
      @band = Band.where(:name => params[:band_name]).includes(:band_members).first
      
    else
      redirect_to root_url and return
    end
  end
  
  def members
    begin
      @band = Band.where(:name => params[:band_name]).includes(:band_members).first
      if current_user.is_admin_of_band?(@band)
         @band_members = @band.band_members
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to access band members of band with band id: #{@band.id} which he is not a admin" 
        redirect_to user_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to user_home_url, :notice => 'Something went wrong! Try Again' and return
    end
    respond_to do |format|
      format.html
      format.js
    end    
  end
  
  def invite_bandmates
    begin
      @band = Band.where(:name => params[:band_name]).first
      if current_user.is_admin_of_band?(@band)
        5.times { @band.band_invitations.new}
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to invite bandmate for a band with band id: #{@band.id} which he is not a admin" 
        redirect_to user_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to user_home_url, :notice => 'Something went wrong! Try Again' and return
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
        redirect_to user_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to user_home_url, :notice => 'Something went wrong! Try Again' and return
    end
  end
  respond_to do |format|
    format.js {render :action => 'invite_bandmates' and return}
  end
  
  def follow_band
    begin
      @band = Band.where(:name => params[:band_name]).first
      current_user.follow(@band)  unless current_user.following?(@band)
    rescue
      render :nothing => true and return
    end
  end
  
  def send_message
    begin
      to_band = Band.find(params[:id])
      if current_user.send_message(to_band, :body => params[:body])
      else
        # though body is empty, let the bogus user feel msg is sent   
      end
    rescue
      render :nothing => true and return
    end
  end
  
  def new_message
    begin
      @band = Band.find(params[:id]) 
      @message = ActsAsMessageable::Message.new
    rescue
      render :nothing => true and return
    end
  end
  
end