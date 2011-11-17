class ProfileController < ApplicationController
  before_filter :require_login
  
  
  def user_profile
   #for other users
   @user = User.find(params[:id])
   if @user
    @user_posts    = UserPost.listing @user, params[:page]
    @user_post_dates = @user_posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
      next_page           = @user_posts.next_page
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
      redirect_to root_url and return unless current_user.additional_info.nil?
      @additional_info = current_user.build_additional_info(params[:additional_info])
      respond_to do |format| 
        @additional_info.save
        format.js          
      end
    else
      redirect_to root_url and return
    end
  end
  
  def add_payment_info
    if request.xhr?
      redirect_to root_url and return unless current_user.payment_info.nil?
      @payment_info = current_user.build_payment_info(params[:payment_info])
      respond_to do |format|
        @payment_info.save
        format.js
      end
    else
      redirect_to root_url and return
    end
  end
  
  def invite_bandmates
     redirect_to root_url and return unless current_user.account_type
    
    if request.post?
      
      @band=Band.find(current_user.band_user.band_id)
      #raise params.inspect
      @band.update_attributes(params[:band])
      redirect_to user_home_url
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
  
end
