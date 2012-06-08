class BandTourController < ApplicationController
  before_filter :require_login
  before_filter :check_and_set_admin_access, :only =>[:new, :create, :edit, :update, :destroy_tour, :band_tours, :band_tour]
  before_filter :instantiate_band_tour, :only =>[:edit, :destroy_tour, :band_tour, :like_dislike_band_tour]
  

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
      if current_user.is_admin_of_band?(@band)
        @band_tour = @band.band_tours.build(params[:band_tour])
        if @band_tour.save
        else
          render :action => 'new'
        end
      else
        render :nothing => true and return
      end
    rescue =>exp
      logger.error "Error in BandTour#Create :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  def edit
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin            
      unless @has_admin_access
        render :noting => true and return
      end
    rescue =>exp
      logger.error "Error in BandTour#Edit :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  def update
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin      
      if @has_admin_access
        @band_tour = BandTour.find(params[:id])
        @band_tour.update_attributes(params[:band_tour])        
      else        
        render :noting => true and return
      end
    rescue =>exp
      logger.info {"Error in BandTour::Update :#{exp.message}"}
      render :nothing => true and return
    end
  end

  def band_tours    
    begin            
      @band_shows       = @band.band_tours
      get_artist_objects_for_right_column(@band)
    rescue =>exp
      logger.error "Error in BandTour#BandTours :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  def band_tour    
    begin            
      @status           = true
      @band_shows       = [@band_tour]
      @show_all         = true
      get_artist_objects_for_right_column(@band)
      render :template =>"/band_tour/band_tours" and return
    rescue =>exp
      logger.error "Error in BandTour#BandTour :=> #{exp.message}"
      @status = false
      render :nothing => true and return
    end
  end

  def band_tour_detail
    @band_tour        = BandTour.find(params[:band_tour_id])
    unless request.xhr?      
      redirect_to show_band_path(:band_name => params[:band_name]) and return
    end
  end

  def like_dislike_band_tour        
  end

  def destroy_tour
    if request.xhr?
      begin                
        unless @has_admin_access
          render :nothing => true and return
        end
        @status = @band_tour.destroy
      rescue
        @status = false
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end
  end

  private

  # finds the artist profile by band_name parameter, and checks whether the current login is artist or fan
  # and accordingly sets the variable @has_admin_access to be used in views and other actions
  def check_and_set_admin_access
    @band             = Band.where(:name => params[:band_name]).first
    @actor            = current_actor
    @has_admin_access = @band == @actor
  end

  def instantiate_band_tour
    begin
      @band_tour        = BandTour.find(params[:band_tour_id])
    rescue
      @badn_tour        = nil      
    end
    unless @band_tour
      render :template =>'/bricks/page_missing' and return
    end
  end

end
