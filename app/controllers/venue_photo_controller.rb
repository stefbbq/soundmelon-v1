class VenuePhotoController < ApplicationController
  before_filter :require_login
  before_filter :check_and_set_admin_access

  def index
    begin
      @album_list  = @has_admin_access ? @venue.albums.includes('photos') : @venue.albums.published.includes('photos')
      get_venue_objects_for_right_column(@venue, @has_admin_access)
    rescue =>exp
      logger.error "Error in VenuePhoto::Index :=> #{exp.message}"
      render :nothing => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def venue_album
    begin
      @album              = @venue.albums.where('id  = ?', params[:album_id]).includes('photos').first
      @status             = true
      @album_list         = [@album]
      @show_all           = true
      get_venue_objects_for_right_column(@venue, @has_admin_access)
      render :template =>"/venue_photo/index" and return
    rescue =>exp
      logger.error "Error in VenuePhoto#Album :=> #{exp.message}"
      @status           = false
      render :nothing   => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    redirect_to show_venue_path(params[:venue_name]) and return unless request.xhr?
    begin
      @album            = @venue.albums.where(:id => params[:album_id]).first
      @photo            = Photo.find(params[:id])
    rescue =>exp
      logger.error "Error in VenuePhoto::Show :#{exp.message}"
      render :nothing => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def new
    redirect_to show_venue_path(params[:venue_name]) and return unless request.xhr?
    if @has_admin_access
      @post_url   = '/venue_photo/create'
      @photo      = Photo.new
      @album      = Album.new
    else
      render :nothing => true and return
    end
  end

  def create
    begin
      if true
        @has_link_access = true
        newparams = coerce(params)
        if params[:album_name].blank?
          params[:album_name] = @venue.name + Time.now.strftime("%Y-%m-%d")
        end
        @album         = @venue.albums.where(:name => params[:album_name]).first        
        unless @album
          @album       = @venue.albums.build(:name=>params[:album_name], :user_id => current_user.id)
          @album.save          
          # delay to avoid the same created_at timestamp for both photos and photo albums
          sleep 1
        end
        @photo         = @album.photos.build(newparams[:photo])
        @photo.user_id = current_user.id
        if @photo.save
          @album.save
          flash[:notice]    = "Successfully created upload."
          respond_to do |format|
            format.html {redirect_to user_home_url and return}
            format.json {render :json =>
                {
                :result         => 'success',
                :album_id       => @album.id,
                :photo_count_str=> @album.photos.size,
                :upload         => @photo.image.url(:thumb),
                :album_name     => @album.name,
                :image_string   => 'assets/profile/venue-defaults-avatar.jpg',
                :image_src      => (cover_image = @album.cover_image) ? cover_image.image.url(:thumb) : '/assets/no-image.png',
                :add_url        => "#{add_photos_to_venue_album_path('home', @album.id)}",
                :album_url      => "#{venue_album_path('home', @album.id)}",
                :delete_url     => "#{delete_venue_album_path('home', @album.id)}",
                :album_photos_url=>"#{venue_album_photos_path('home', @album.id)}",
                :album_string   => "#{render_to_string('/venue_photo/_album', :layout =>false, :locals =>{:album =>@album, :has_admin_access=>true})}",
                :photo_string   => "#{render_to_string('/venue_photo/_photo', :layout =>false, :locals =>{:album =>@album, :photo =>@photo})}"
              }
            }
          end
        else
          render :action => 'new'
        end
      else
        render :nothing => true and return
      end
    rescue =>exp
      logger.error "Error in VenuePhotos::Create :=>#{exp.message}"
      render :nothing => true and return
    end
  end

  def venue_album_photos
    redirect_to show_venue_path(params[:venue_name]) and return unless request.xhr?
    begin
      @album       = @venue.albums.where(:id => params[:album_id]).includes('photos').first
    rescue =>exp
      logger.error "Error in VenuePhoto#AlbumPhotos :=> #{exp.message}"
      render :nothing   => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def add
    if request.xhr?
      begin
        @album       = @venue.albums.where(:id => params[:album_id]).first
        if @has_admin_access
          @post_url  = '/venue_photo/create'
          @photo     = Photo.new
        else
          # render :nothing => true and return
        end
        render :action    => 'new', :format => 'js' and return
      rescue =>exp
        logger.error "Error in VenuePhoto#Add :=> #{exp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_venue_url(params[:venue_name]) and return
    end
  end

  def edit
    if request.xhr?
      begin
        @album       = @venue.albums.where('id = ? ', params[:album_id]).first
        unless @has_admin_access
          render :nothing => true and return
        end        
      rescue =>excp
        logger.error "Error in VenuePhoto::Edit :=>#{excp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_venue_url(params[:venue_name]) and return
    end
  end

  def update
    if request.xhr?
      begin        
        @album          = @venue.albums.where('id = ?', params[:album_id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @album.update_attributes(params[:album])
        @has_link_access = true
      rescue =>exp
        logger.info exp.message
        render :nothing => true and return
      end
    else
      redirect_to show_venue_url(params[:venue_name]) and return
    end
  end

  def destroy_album
    if request.xhr?
      begin
        @album       = @venue.albums.where('id = ? ', params[:album_id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @status           = @album.destroy
      rescue =>exp
        logger.error "Error in VenuePhoto::DestroyAlbum :#{exp.message}"
        @status           = false
        render :nothing => true and return
      end
    else
      redirect_to show_venue_url(params[:venue_name]) and return
    end
  end

  def edit_photo
    if request.xhr?
      begin
        @album       = @venue.albums.where('id  = ?', params[:album_id]).first
        @photo       = Photo.where(:album_id => @album.id, :id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @has_link_access    = true
      rescue =>excp
        logger.error "Error in VenuePhoto::EditPhoto :#{excp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_venue_url(params[:venue_name]) and return
    end
  end

  def update_photo
    if request.xhr?
      begin
        @album       = @venue.albums.where('id  = ?', params[:album_id]).first
        @photo       = Photo.where(:id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @photo.update_attributes(params[:photo])
        @has_link_access    = true
      rescue =>exp
        logger.error "Error in VenuePhoto#UpdatePhoto :=> #{exp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_venue_url(params[:venue_name]) and return
    end
  end

  def make_cover_image
    if request.xhr?
      begin
        @album       = @venue.albums.where('id  = ?', params[:album_id]).first
        @photo       = Photo.where(:id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @album.set_the_cover_image(@photo, true)
        @has_link_access    = true
      rescue =>exp
        logger.error "Error in VenuePhoto#MakeCoverImage :=> #{exp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_venue_url(params[:venue_name]) and return
    end
  end

  def destroy
    if request.xhr?
      begin        
        @album       = @venue.albums.where('id  = ?', params[:album_id]).first
        @photo       = Photo.where(:id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @photo.destroy
        @album.choose_cover_image
        @has_link_access    = true
      rescue =>exp
        logger.error "Error in VenuePhoto::Destroy :=>#{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_venue_url(params[:venue_name]) and return
    end
  end

  def disable_enable_album
    redirect_to show_venue_path(params[:venue_name]) and return unless request.xhr?
    begin
      @is_admin_of_venue  = current_user.is_member_of_venue?(@venue)
      @album              = @venue.albums.where('id  = ?', params[:album_id]).first      
      @album.disabled ? @album.enable : @album.disable
      @status             = true
    rescue =>exp
      logger.error "Error in VenuePhoto::DisableEnableAlbum :#{exp.message}"
      @status             = false
      render :nothing     => true and return
    end
  end

  def like_dislike
    redirect_to show_venue_path(params[:venue_name]) and return unless request.xhr?
    begin
      @is_admin_of_venue = current_user.is_member_of_venue?(@venue)
      @album             = @venue.albums.where('id  = ?', params[:album_id]).first
      @status            = true
    rescue
      @status            = false
      render :nothing => true and return
    end
  end

  private

  def coerce(params)
    if params[:photo].nil?
      h = Hash.new
      h[:photo] = Hash.new
      h[:photo][:image] = params[:Filedata]
      h[:photo][:image].content_type = MIME::Types.type_for(h[:photo][:image].original_filename).to_s
      h
    else
      params
    end
  end

  # finds the venue profile by venue_name parameter, and checks whether the current login is venue or fan
  # and accordingly sets the variable @has_admin_access to be used in views and other actions
  def check_and_set_admin_access
    begin
      if params[:venue_name] == 'home'
        @venue            = @actor
        @has_admin_access = @venue == @actor
        @has_link_access  = @has_admin_access
        @is_homepage      = true
      else
        @venue            = Venue.where(:mention_name => params[:venue_name]).first
        @has_admin_access = @venue == @actor
        @is_public        = true
        @has_link_access  = false        
      end
    rescue =>exp
      logger.error "Error in VenuePhoto::CheckAndSetAdminAccess :=>#{exp.message}"
      @venue             = nil
    end
    unless @venue
      render :template =>"bricks/page_missing" and return
    end
  end
end
