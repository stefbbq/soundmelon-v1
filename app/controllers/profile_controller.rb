class ProfileController < ApplicationController
  before_filter :require_login
  
  
  def user_profile
    
   #for other users
   @user = User.find(params[:id])
   if @user && @user!=current_user
    @posts    =  @user.find_own_as_well_as_mentioned_posts(params[:page])
    @posts_order_by_dates = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page           = @posts.next_page
      @load_more_path =  next_page ?  more_post_path(next_page) : nil
     
   else
     redirect_to user_home_path, :error => "No user has been found with this user id"
     
   end      
  end
  
  def additional_info
    @user = current_user
    @additional_info = @user.additional_info
    @payment_info = @user.payment_info
    #redirect_to user_home_url and return if !@additional_info.nil? || !@payment_info.nil?
  end

  def add_additional_info
    if request.xhr?
      #redirect_to root_url and return unless current_user.additional_info.nil?
      if current_user.additional_info.nil?
        @additional_info = current_user.build_additional_info(params[:additional_info])
        @additional_info.save
      else
        @additional_info_update = true
        @additional_info = current_user.additional_info
         @additional_info.update_attributes(params[:additional_info])
      end
      respond_to do |format| 
        format.js          
      end
    else
      redirect_to root_url and return
    end
  end
  
  def add_payment_info
    if request.xhr?
      if current_user.payment_info.nil?
        @payment_info = current_user.build_payment_info(params[:payment_info])
        @payment_info.save
      else
        @payment_info = current_user.payment_info
        @payment_info.update_attributes(params[:payment_info])
        @payment_info_update = true
      end
      respond_to do |format|
        format.js
      end
    else
      redirect_to root_url and return
    end
  end
    
  def invite_bandmates
    redirect_to root_url and return unless current_user.account_type
    
    if request.post?
      @band = current_user.bands.first
      @band.update_attributes(params[:band])
      redirect_to user_home_url and return
    else
     @band = Band.new
     @band_invitations = @band.band_invitations.build
    end
  end
  
  def activate_invitation
    
    unless params[:id].blank?
      band_invitation = BandInvitation.find_by_token(params[:id])
      if band_invitation
        band_user = BandUser.new(:band_id => band_invitation.band_id,
                               :user_id => current_user.id,
                               :access_level => band_invitation.access_level
                               ) 
        band_user.save
        band_invitation.update_attribute(:token, nil)
        redirect_to user_home_url, :notice => "You have successfully joined the band." and return
      else
        redirect_to user_home_url ,:error => "Invitation token has been already used or token missmatch" and return
      end
    else
      redirect_to user_home_url ,:error => "Undefined invitation token" and return
    end
  end
 
  def edit_profile
    if request.xhr?
      begin
        @user = current_user
        @additional_info = current_user.additional_info
        respond_to do |format|
          format.js and return
        end
      rescue
        render :nothing => true and return   
      end
    else
      redirect_to user_home_url and return
    end
  end
  
  def update_basic_info
    if request.xhr?
      begin
        if params[:user][:fname].blank? || params[:user][:fname].blank?
          @msg = 'First Name and Last Name cannot be blank'
        else
          current_user.fname = params[:user][:fname]
          current_user.lname = params[:user][:lname]
          if current_user.save
            @msg = 'Basic info updated successfully'
          else
            @msg = 'Something went wrong. Try again'
          end
        end
        respond_to do |format|
          format.js and return
        end
      rescue
        render :nothing => true and return   
      end
    else
      redirect_to user_home_url and return
    end
  end
  
  def update_password
    if request.xhr?
      begin
        if params[:old_password].blank?
          @msg = 'Old password do not match'
        elsif params[:user][:password].blank? || params[:user][:password_confirmation].blank?
          @msg = 'New password cannot be blank'
        elsif params[:user][:password] != params[:user][:password_confirmation]
          @msg = 'New password do not match'
        elsif !login(current_user.email, params[:old_password])
          @msg = 'Old password do not match'    
        else
         if current_user.change_password!(params[:user][:password])
            @msg = 'Password updated successfully'
          else
            @msg = 'Something went wrong. Try again'
          end
        end
        respond_to do |format|
          format.js and return
        end
      rescue
        render :nothing => true and return   
      end
    else
      redirect_to user_home_url and return
    end   
  end
  
  def update_payment_info
     if request.xhr?
       @payment_info = current_user.payment_info
     else
       redirect_to user_home_url and return
     end
  end
end
