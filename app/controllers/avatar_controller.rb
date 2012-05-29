class AvatarController < ApplicationController
  before_filter :require_login

  def new
    begin @user = User.find params[:id] rescue @user=nil end
    @profile_pic = @user.build_profile_pic
    respond_to do |format|
      format.js
    end
  end

  def create
    begin
      @user         = User.find(params[:profile_pic][:user_id])
      @profile_pic  = @user.build_profile_pic(params[:profile_pic])
    rescue =>exp
      logger.error "Error: #{exp.message}"
      @user=nil
    end
    respond_to do |format|
      if @profile_pic.save
        format.js { render :action => 'crop' and return }
      else
        format.js { render :action => 'new' and return}
      end
    end
  end

  def edit
    begin
      @user        = User.find params[:id]
      @profile_pic = @user.profile_pic
    rescue
      @profile_pic = nil
    end
  end

  def update
    begin
      @user        = User.find params[:id]
      @profile_pic = @user.profile_pic
    rescue
    end
    if @profile_pic.update_attributes(params[:profile_pic])
      respond_to do |format|
        format.js
      end
    end
  end

  def crop
    begin
      @user        = User.find params[:id]
      @profile_pic = @user.profile_pic
    rescue =>exp
      logger.error "Error : #{exp.message}"
      @profile_pic = nil
    end
  end

  def delete
    begin
      @user        = User.find params[:id]
      @profile_pic = @user.profile_pic
    rescue
      @profile_pic = nil
    end
    redirect_to fan_home_url and return unless @profile_pic
    if @profile_pic.delete
      respond_to do |format|
        format.js
      end
    end
  end

end
