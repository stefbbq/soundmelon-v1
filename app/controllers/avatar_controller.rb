class AvatarController < ApplicationController
  before_filter :require_login
  
  def new
    @profile_pic = ProfilePic.new
    respond_to do |format|
      format.js
    end
  end
  
  def create
    @profile_pic = current_user.build_profile_pic(params[:profile_pic])
    respond_to do |format|
      if @profile_pic.save
        format.js { render :action => 'crop' and return }
      else
        format.js { render :action => 'new' and return}
      end
    end    
  end
  
  def edit
    @profile_pic = current_user.profile_pic
  end
  
  def update
    @profile_pic = current_user.profile_pic
    if @profile_pic.update_attributes(params[:profile_pic])
        respond_to do |format|
          format.js
        end     
    end
  end
  
  def crop
    begin
      @profile_pic = current_user.profile_pic
    rescue
      @profile_pic = nil
    end    
  end
  
  def delete
    redirect_to fan_home_url and return if current_user.profile_pic.nil?
    if current_user.profile_pic.delete
      respond_to do |format|
        format.js
      end
    end
  end
end
