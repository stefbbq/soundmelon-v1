class BandPhotosController < ApplicationController 
  before_filter :require_login
  
  def index
    #@photos = Photos.all
  end
  
  def show
    begin
      @band = Band.where(:name => params[:band_name]).first
      if current_user.is_member_of_band?(@band)
        @band_album = BandAlbum.where('band_id = ? and name = ?', @band.id, params[:band_album_name]).first
        @photo = BandPhoto.find(params[:id])
        render :nothing => true and return unless @photo.band_album_id == @band_album.id
      else
        render :noting => true and return
      end
    rescue
      render :nothing => true and return
    end       
  end

  def new
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
        @band_album = BandAlbum.where(:name => params[:album_name], :band_id => @band.id).first || BandAlbum.create(:name=>params[:album_name], :user_id => current_user.id, :band_id => @band.id)
        @band_photo = @band_album.band_photos.build(newparams[:band_photo])
        @band_photo.user_id = current_user.id
        if @band_photo.save
          flash[:notice] = "Successfully created upload."
          respond_to do |format|
           format.html {redirect_to user_home_url and return}
           format.json {render :json => { :result => 'success', :upload => @band_photo.image.url(:thumb), :album_name => @band_album.name } }
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

  def destroy

  end
  
  def band_albums
   begin
     @band = Band.where(:name => params[:band_name]).first
     if current_user.is_member_of_band?(@band)
       @band_albums = @band.band_albums.includes('band_photos')
     else
       render :noting => true and return
     end
   rescue
     render :nothing => true and return
   end
  end
  
  def band_album_photos
   begin
     @band = Band.where(:name => params[:band_name]).first
     if current_user.is_member_of_band?(@band)
       @band_album = BandAlbum.where('band_id = ? and name = ?', @band.id, params[:band_album_name]).includes('band_photos').first
     else
       render :noting => true and return
     end
   rescue
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
end