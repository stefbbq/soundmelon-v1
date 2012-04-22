class BandTourController < ApplicationController
    before_filter :require_login

  def index
    #@photos = Photos.all
  end

  def show
    begin
      @band = Band.where(:name => params[:band_name]).first
      @band_album = BandAlbum.where('band_id = ? and name = ?', @band.id, params[:band_album_name]).first
      @photo = BandPhoto.find(params[:id])
    rescue
      render :nothing => true and return
    end
  end

  def new
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    @band = Band.where(:name => params[:band_name]).first
    if current_user.is_admin_of_band?(@band)
      @band_photo = BandPhoto.new
    else
      render :nothing => true and return
    end
  end

  def create
    begin
      @band = Band.where(:name => params[:band_name]).first
      if current_user.is_admin_of_band?(@band)
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

  def band_tours
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin
      @band = Band.where(:name => params[:band_name]).first
      @is_admin_of_band = current_user.is_member_of_band?(@band)
      @band_albums = @band.band_albums.includes('band_photos')
    rescue
      render :nothing => true and return
    end
  end

  def band_tour
    redirect_to show_band_path(:band_name => params[:band_name]) and return unless request.xhr?
    begin
      @band = Band.where(:name => params[:band_name]).first
      @is_admin_of_band = current_user.is_member_of_band?(@band)
      @band_album = BandAlbum.where('band_id = ? and name = ?', @band.id, params[:band_album_name]).includes('band_photos').first
      @status = true
    rescue
      @status = false
      render :nothing => true and return
    end
  end
  
end
