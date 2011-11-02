class ProfileController < ApplicationController
  before_filter :require_login
  
  def additional_info
    @user = current_user
    @additional_info = @user.additional_info
    @payment_info = @user.payment_info
    redirect_to user_home_url and return if !@additional_info.nil? || !@payment_info.nil?
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
      raise params.inspect
      @band.update_attributes(params[:band])
    else
     @band = Band.new
     @band_invitations = @band.band_invitations.build
      
    end
  end
  
end
