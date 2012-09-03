class VenueController < ApplicationController
  layout 'layouts/popup', :only =>[:new, :create, :add_info]
  
  def index    
  end

  def new
    @user                  = current_user
    session[:venue_params] ||= {}
    @venue                 = Venue.new(session[:venue_params])
    @venue.current_step    = session[:venue_step]    
    #    get_user_associated_objects    
  end

  def create    
    begin
      session[:venue_params]   ||= {}
      session[:venue_params].deep_merge!(params[:venue]) if params[:venue]      
      @venue                   = Venue.new(session[:venue_params])
      @venue.current_step      = session[:venue_step]
      if @venue.valid?
        if params[:back_button]
          @venue.previous_step
        elsif @venue.last_step?
          if @venue.all_valid? && @venue.save
            venue_user                 = current_user.venue_users.new
            venue_user.venue_id       = @venue.id
            venue_user.access_level    = 1
            venue_user.save
          end
        else
          @venue.next_step
        end
        session[:venue_step]     = @venue.current_step
      end      
    rescue =>excp
      logger.error "Error in Venue::Create :#{excp.message}"
    end

    if @venue.new_record?
      render "new" and return
    else
      session[:venue_step]  = session[:venue_params] = nil
      flash[:notice]        = "Venue profile created"
      redirect_to venue_add_info_path(@venue.id) and return
    end    
  end

  def edit
  end

  def update
    @venue      = Venue.find(params[:id])
    @user       = current_user
    get_venue_objects_for_right_column(@venue)
    if current_user.is_admin_of_venue?(@venue)
      if @venue.update_attributes(params[:venue])
        respond_to do |format|
          format.js
        end
      else
        respond_to do |format|
          format.js {render :action => 'edit' and return}
        end
      end
    else
      logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to update artist with venue id: #{@venue.id} which he is not a admin"
      render :nothing => true and return
    end
  end

  def update_notification_setting
    if request.xhr?
      @updated            = false
      venue               = Venue.find(params[:id])
      if venue
        venue_user        = VenueUser.for_user_and_venue(current_user, venue).first
        venue_user.toggle! :notification_on if venue_user
        @status          = venue_user.notification_on ? 'on' : 'off'
        @updated         = true
      end
    else
      redirect_to fan_home_url and return
    end
  end

  def state_options
    render :partial =>'venue/state_selection' and return
  end

  def add_info
    begin
      @venue = Venue.find params[:id]
    rescue =>exp
      logger.errror "Error in Venue::AddInfo :=>#{exp.message}"
    end
    if @venue
      if request.get?
      else
        @status     = @venue.update_attributes(params[:venue])
        if @status
          @artists  = Genre.get_artists_for_genres @venue.genres
        end
      end
    end
  end

end
