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

  def new_logo
    begin @artist     = Band.find params[:id] rescue @artist=nil end
    @artist_logo      = @artist.build_band_logo
    respond_to do |format|
      format.js
    end
  end

  def create_logo
    begin
      @artist         = Band.find(params[:band_logo][:band_id])
      @artist_logo    = @artist.build_band_logo(params[:band_logo])
    rescue =>exp
      logger.error "Error: #{exp.message}"
      @artist         = nil
    end
    respond_to do |format|
      if @artist_logo.save
        format.js { render :action => 'crop_logo' and return }
      else
        format.js { render :action => 'new_logo' and return}
      end
    end
  end

  def edit_logo
    begin
      @artist        = Band.find params[:id]
      @artist_logo   = @artist.band_logo
    rescue
      @artist_logo   = nil
    end
  end

  def update_logo
    begin
      @artist        = Band.find params[:id]
      @artist_logo   = @artist.band_logo
    rescue
    end
    if @artist_logo.update_attributes(params[:band_logo])
      respond_to do |format|
        format.js
      end
    end
  end

  def crop_logo
    begin
      @artist        = Band.find params[:id]
      @artist_logo   = @artist.band_logo
    rescue =>exp
      logger.error "Error : #{exp.message}"
      @artist_logo = nil
    end
  end

  def delete_logo
    begin
      @artist        = Band.find params[:id]
      @artist_logo   = @artist.band_logo
    rescue
      @artist_logo   = nil
    end
    redirect_to fan_home_url and return unless @artist_logo
    if @artist_logo.delete
      respond_to do |format|
        format.js
      end
    end
  end

end
