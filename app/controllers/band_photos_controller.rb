class BandPhotosController < ApplicationController 
  before_filter :require_login, :check_and_set_admin_access
  
  def index    
  end
  
  def show
    begin
      @band           = Band.where(:name => params[:band_name]).first
      @band_album     = BandAlbum.where('band_id = ? and name = ?', @band.id, params[:band_album_name]).first
      @photo          = BandPhoto.find(params[:id])
    rescue
      render :nothing => true and return
    end       
  end

  def new
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    @band             = Band.where(:name => params[:band_name]).first
    if @has_admin_access
      @band_photo     = BandPhoto.new
    else
      render :nothing => true and return
    end
  end

  def create
    begin      
      if @has_admin_access
        newparams = coerce(params)
        if params[:album_name].blank?
          params[:album_name] = Time.now.strftime("%Y-%m-%d")
        end
        @band_album         = BandAlbum.where(:name => params[:album_name], :band_id => @band.id).first || BandAlbum.create(:name=>params[:album_name], :user_id => current_user.id, :band_id => @band.id)        
        @band_photo         = @band_album.band_photos.build(newparams[:band_photo])
        @band_photo.user_id = current_user.id
        if @band_photo.save
          @band_album       = @band_photo.band_album
          flash[:notice] = "Successfully created upload."
          respond_to do |format|
            format.html {redirect_to user_home_url and return}
            format.json {render :json =>
                {
                :result         => 'success',
                :band_album_id  => @band_album.id,
                :photo_count_str=> @band_album.photo_count,
                :upload         => @band_photo.image.url(:thumb),
                :album_name     => @band_album.name,
                :image_string   => '',
                :image_src      => @band_album.photo_count>0 ? @band_album.band_photos.first.image.url(:thumb) : '/assets/no-image.png',
                :add_url        => "#{add_photos_to_album_path(:band_name =>@band.name, :band_album_name =>@band_album.name)}",
                :album_url      => "#{band_album_path(:band_name =>@band.name, :band_album_name =>@band_album.name)}",
                :delete_url     => "#{delete_album_path(:band_name =>@band.name, :band_album_name =>@band_album.name)}"
              }
            }
          end
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
  
  def band_albums        
    begin
      @band             = Band.where(:name => params[:band_name]).first
      @band_albums      = @band.band_albums.includes('band_photos')      
      get_artist_objects_for_right_column(@band)
    rescue
      render :nothing => true and return
    end
  end

  def band_album    
    begin
      @band             = Band.where(:name => params[:band_name]).first
      @band_album       = BandAlbum.where('band_id = ? and name = ?', @band.id, params[:band_album_name]).includes('band_photos').first
      @status           = true
      @band_albums      = [@band_album]
      @show_all         = true
      get_artist_objects_for_right_column(@band)
      render :template =>"/band_photos/band_albums" and return
    rescue =>exp
      logger.error "Error in BandPhoto#BandAlbum :=> #{exp.message}"
      @status           = false
      render :nothing   => true and return
    end
  end
  
  def band_album_photos
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin            
      @band_album       = BandAlbum.where('band_id = ? and name = ?', @band.id, params[:band_album_name]).includes('band_photos').first
    rescue =>exp
      logger.error "Error in BandPhoto#BandAlbumPhotos :=> #{exp.message}"
      render :nothing   => true and return
    end
  end
  
  def add
    if request.xhr?
      begin        
        @band_album       = BandAlbum.where(:name => params[:band_album_name], :band_id => @band.id).first
        if @has_admin_access
          @band_photo     = BandPhoto.new
        else
          # render :nothing => true and return
        end
        render :action    => 'new', :format => 'js' and return
      rescue =>exp
        logger.error "Error in BandPhoto#Add :=> #{exp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end
  end
  
  def edit
    if request.xhr?
      begin
        @band             = Band.where(:name => params[:band_name]).first
        @band_album       = BandAlbum.where(:name => params[:band_album_name], :band_id => @band.id).includes(:band_photos).first
        unless current_user.is_admin_of_band?(@band)          
          render :nothing => true and return
        end
      rescue        
        render :nothing   => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end
  end

  def update
    if request.xhr?
      begin
        @band           = Band.where(:name => params[:band_name]).first
        @band_album     = BandAlbum.where(:name => params[:band_album_name], :band_id => @band.id).includes(:band_photos).first
        unless current_user.is_admin_of_band?(@band)
          render :nothing => true and return
        end        
        @band_album.update_attributes(params[:band_album])
      rescue =>exp
        logger.info exp.message
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end
  end
  
  def destroy_album
    if request.xhr?
      begin        
        @band_album       = BandAlbum.where(:name => params[:band_album_name], :band_id => @band.id).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @status           = @band_album.delete
      rescue
        @status           = false
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end
  end
  
  def edit_photo
    if request.xhr?
      begin
        @band             = Band.where(:name => params[:band_name]).first
        @band_album       = BandAlbum.where(:name => params[:album_name], :band_id => @band.id).first
        @band_photo       = BandPhoto.where(:band_album_id => @band_album.id, :id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
      rescue
        render :nothing   => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end  
  end
  
  def update_photo
    if request.xhr?
      begin                
        @band_album       = BandAlbum.where(:name => params[:album_name], :band_id => @band.id).first
        @band_photo       = BandPhoto.where(:band_album_id => @band_album.id, :id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @band_photo.update_attributes(params[:band_photo])
      rescue =>exp
        logger.error "Error in BandPhoto#UpdatePhoto :=> #{exp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end
  end

  def make_cover_image
    if request.xhr?
      begin        
        @band_album       = BandAlbum.where(:name => params[:album_name], :band_id => @band.id).first
        @band_photo       = BandPhoto.where(:band_album_id => @band_album.id, :id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @band_album.set_the_cover_image(@band_photo, true)
        render :template =>'/band_photos/band_album_photos'
      rescue =>exp
        logger.error "Error in BandPhoto#MakeCoverImage :=> #{exp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end  
  end
  
  def destroy
    if request.xhr?
      begin        
        @band_album       = BandAlbum.where(:name => params[:album_name], :band_id => @band.id).first
        @band_photo       = BandPhoto.where(:band_album_id => @band_album.id, :id => params[:id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @band_photo.destroy
        @band_album.choose_cover_image
        render :template =>'/band_photos/band_album_photos'
      rescue
        render :nothing => true and return
      end
    else
      redirect_to show_band_url(params[:band_name]) and return
    end
  end
  
  def disable_enable_band_album
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin      
      @is_admin_of_band   = current_user.is_member_of_band?(@band)
      @band_album         = BandAlbum.where('band_id = ? and name = ?', @band.id, params[:album_name]).includes('band_photos').first
      @band_album.update_attribute(:disabled, !@band_album.disabled)
      @status             = true
    rescue
      @status             = false
      render :nothing     => true and return
    end   
  end

  def like_dislike
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin      
      @is_admin_of_band = current_user.is_member_of_band?(@band)
      @band_album       = BandAlbum.where('band_id = ? and name = ?', @band.id, params[:album_name]).includes('band_photos').first
#      @band_album.update_attribute(:disabled, !@band_album.disabled)
      @status = true
    rescue
      @status = false
      render :nothing => true and return
    end
  end

  private
  
  def coerce(params)
    if params[:band_photo].nil? 
      h = Hash.new 
      h[:band_photo] = Hash.new  
      h[:band_photo][:image] = params[:Filedata] 
      h[:band_photo][:image].content_type = MIME::Types.type_for(h[:band_photo][:image].original_filename).to_s
      h
    else 
      params
    end 
  end

  # finds the artist profile by band_name parameter, and checks whether the current login is artist or fan
  # and accordingly sets the variable @has_admin_access to be used in views and other actions
  def check_and_set_admin_access
    @band             = Band.where(:name => params[:band_name]).first
    @actor            = current_actor
    @has_admin_access = @band == @actor    
  end
  
end