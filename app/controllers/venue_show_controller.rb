class VenueShowController < ApplicationController
  before_filter :require_login
  before_filter :check_and_set_admin_access

  def index
    begin
      @venue_show_list = @venue.artist_shows
      get_venue_objects_for_right_column(@venue)
    rescue =>exp
      logger.error "Error in VenueShow#Index :=> #{exp.message}"
      render :nothing => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  private

  # finds the artist profile by artist_name parameter, and checks whether the current login is artist or fan
  # and accordingly sets the variable @has_admin_access to be used in views and other actions
  def check_and_set_admin_access
    begin
      if params[:venue_name] == 'home'
        @venue            = @actor
        @has_admin_access = @venue == @actor
        @has_link_access  = @has_admin_access
      else
        @venue            = Venue.where(:mention_name => params[:venue_name]).first
        @has_admin_access = @venue == @actor
        @is_public        = true
        @has_link_access  = false
      end
    rescue
      @venue             = nil
    end
    unless @venue
      render :template =>"bricks/page_missing" and return
    end
  end
  
end
