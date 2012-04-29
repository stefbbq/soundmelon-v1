class BandTourController < ApplicationController
    before_filter :require_login

  def index
    #@photos = Photos.all
  end

  def show
    begin
      @band       = Band.where(:name => params[:band_name]).first
      @band_album = BandTour.where('band_id = ? and id = ?', @band.id, params[:id]).first
      @photo      = BandPhoto.find(params[:id])
    rescue
      render :nothing => true and return
    end
  end

  def new
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    @band = Band.where(:name => params[:band_name]).first
    if current_user.is_admin_of_band?(@band)
      @band_tour = BandTour.new
    else
      render :nothing => true and return
    end
  end

  def create
    begin
      @band = Band.where(:name => params[:band_name]).first
      if current_user.is_admin_of_band?(@band)
        @band_tour = @band.band_tours.build(params[:band_tour])
        if @band_tour.save
        else
          render :action => 'new'
        end
      else
        render :nothing => true and return
      end
    rescue
      render :nothing => true and return
    end
  end

  def edit
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin
      @band         = Band.where(:name => params[:band_name]).first
      if current_user.is_member_of_band?(@band)
        @band_tour = BandTour.find(params[:band_tour_id])        
      else
        render :noting => true and return
      end
    rescue
      render :nothing => true and return
    end
  end

  def update
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin
      @band         = Band.where(:name => params[:band_name]).first
      if current_user.is_member_of_band?(@band)
        @band_tour = BandTour.find(params[:id])
        @band_tour.update_attributes(params[:band_tour])        
      else        
        render :noting => true and return
      end
    rescue =>exp
      logger.info {"Error in updating :#{exp.message}"}
      render :nothing => true and return
    end
  end


  def band_tours
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin
      @band             = Band.where(:name => params[:band_name]).first
      @is_admin_of_band = current_user.is_member_of_band?(@band)
      @band_tours       = @band.band_tours
    rescue
      render :nothing => true and return
    end
  end

  def band_tour
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin
      @band             = Band.where(:name => params[:band_name]).first
      @is_admin_of_band = current_user.is_member_of_band?(@band)
      @band_tour        = BandTour.find(params[:band_tour_id])
      @status           = true
    rescue
      @status = false
      render :nothing => true and return
    end
  end

  def band_tour_detail
    if request.xhr?
      begin
        @band             = Band.where(:name => params[:band_name]).first
        @is_admin_of_band = current_user.is_member_of_band?(@band)
        @band_tour        = BandTour.find(params[:band_tour_id])
      rescue
        render :nothing => true and return
      end
    else
      redirect_to show_band_path(:band_name => params[:band_name]) and return
    end
  end

  def like_dislike_band_tour
    @band             = Band.where(:name => params[:band_name]).first
    @band_tour        = BandTour.find(params[:band_tour_id])
  end

  def destroy_tour
    if request.xhr?
      begin
        @band       = Band.where(:name => params[:band_name]).first
        @band_tour  = BandTour.find(params[:band_tour_id])
        unless current_user.is_admin_of_band?(@band)
          render :nothing => true and return
        end
        @status = @band_tour.delete
      rescue
        @status = false
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end
  end
  
end
