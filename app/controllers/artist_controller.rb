class ArtistController < ApplicationController
  before_filter :require_login
  
  def index
    begin
      @band = Band.where(:name => params[:band_name]).includes(:band_members).first
      if @is_admin_of_band         = current_user.is_admin_of_band?(@band)
        get_band_associated_objects(@band)        
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to adminster band with band id: #{@band.id} which he is not a admin" 
        redirect_to fan_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  def new
    @user = current_user
    get_user_associated_objects
    @band = Band.new
  end  
  
  def create
    @band     = current_user.bands.build(params[:band])
    band_user = current_user.band_users.new
    if @band.save
      band_user.band_id       = @band.id
      band_user.access_level  = 1
      band_user.save
      @artists  = current_user.bands.includes(:song_albums, :songs)
    else
      render :action => 'new' and return
    end
  end
  
  def edit    
    begin
      @band = Band.find(params[:id])
      get_artist_objects_for_right_column(@band)
      if current_user.is_admin_of_band?(@band)
        respond_to do |format|
          format.js
          format.html
        end
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to edit band with band id: #{@band.id} which he is not a admin"
        render :nothing => true and return
      end
    rescue =>exp
      logger.error "Error in Artist#Edit :=> #{exp.message}"
      render :template   => "/bricks/page_missing" and return
    end
  end
  
  def update
    @band     = Band.find(params[:id])
    get_artist_objects_for_right_column(@band)
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
    respond_to do |format|
      format.js
      format.html
    end
  end   
  
  def invite_bandmates
    begin
      @band      = Band.where(:name => params[:band_name]).first
      if current_user.is_admin_of_band?(@band)
        1.times { @band.band_invitations.new}
        get_artist_objects_for_right_column(@band)
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