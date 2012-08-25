class VenueController < ApplicationController

  def index    
  end

  def new
    @user     = @actor
    get_user_associated_objects
    @venue    = Venue.new
  end

  def create
    @venue     = current_user.venues.build(params[:venue])
    venue_user = current_user.venue_users.new
    if @venue.save
      venue_user.venue_id      = @venue.id
      venue_user.access_level  = 1
      venue_user.save
      @venues  = current_user.venues
    else
      render :action => 'new' and return
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

end
