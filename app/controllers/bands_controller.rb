class BandsController < ApplicationController
  before_filter :require_login
  
  def index
    @bands = current_user.bands
  end
  
  def manage
    begin
      @band = Band.where(:name => params[:band_name]).includes(:band_members).first
      if current_user.is_admin_of_band?(@band)
         @band_members_count = @band.band_members.count
         @other_bands = current_user.admin_bands_except(@band)
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to adminster band with band id: #{@band.id} which he is not a admin" 
        redirect_to user_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to user_home_url, :notice => 'Something went wrong! Try Again' and return
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
  
end
