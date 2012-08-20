# Handling all the stuffs related to artist music
class ArtistMusicController < ApplicationController
  before_filter :require_login
  before_filter :check_and_set_admin_access, :except =>[:download_album, :download, :do_like_dislike_song ]

  def index
    begin      
      @artist_music_list  = @artist.artist_musics.includes(:songs)
      get_artist_objects_for_right_column(@artist)
    rescue =>exp
      logger.error "Error in ArtistArtistMusic#Index :=> #{exp.message}"
      render :nothing => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def artist_music
    begin      
      @artist_music       = ArtistMusic.where('artist_id = ? and album_name = ?', @artist.id, params[:artist_music_name]).includes(:songs).first
      @artist_music_list  = [@artist_music]
      @show_all           = true
      @highlighted_song_id= params[:h]
      get_artist_objects_for_right_column(@artist)
      render :template  =>"/artist_music/index" and return
    rescue =>exp
      logger.error "Error in ArtistArtistMusic#ArtistArtistMusic :=> #{exp.message}"
      render :nothing => true and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  # renders the form for new song album, :only =>ajax_request
  def new
    redirect_to show_artist_url(params[:artist_name]) and return unless request.xhr?
    if @has_admin_access
      @song         = Song.new
      @artist_music = ArtistMusic.new
    else
      render :nothing => true and return
    end
  end

  # creates the new song album
  def create
    begin
      if @has_admin_access
        @has_link_access = true
        newparams = coerce(params)
        if params[:album_name].blank?
          params[:album_name] = @artist.name + Time.now.strftime("%Y-%m-%d")
        end
        @artist_music         = ArtistMusic.where(:album_name => params[:album_name], :artist_id => @artist.id).first        
        unless @artist_music
          @artist_music       = ArtistMusic.create(:album_name=>params[:album_name], :user_id => current_user.id, :artist_id => @artist.id)
          # delay to avoid the same created_at timestamp for both song album and songs
          sleep 1
        end
        # update cover image
        if params[:music_cover_image].present?
#          @artist_music.update
#          @artist_music.update_attributes(params[:artist_music])
           begin
            @artist_music.update_attribute(:cover_img, params[:music_cover_image])
           rescue =>exp
             logger.error "Error : #{exp.message}"
           end
        end

        @song                 = @artist_music.songs.build(newparams[:song])
        @song.user_id         = current_user.id
        if @song.save
          flash[:notice] = "Song successfully uploaded."
          respond_to do |format|
            format.html {redirect_to manage_artist_url(:artist_name => @artist.name) and return}
            format.json {
              render :json => {
                :result           => 'success',
                :upload           => @song.song_file_name,
                :album_name       => @artist_music.album_name,
                :artist_music_id  => @artist_music.id,
                :song_count_str   => @artist_music.songs.size,
                :image_src        => '/assets/profile/artist-defaults-avatar.jpg',
                :add_url          => "#{add_song_path(@artist, @artist_music.album_name)}",
                :album_url        => "#{artist_music_path(@artist, @artist_music.album_name)}",
                :delete_url       => "#{delete_artist_music_path(@artist, @artist_music.id)}",
                :album_string     => "#{render_to_string('/artist_music/_artist_music',:layout =>false, :locals =>{:artist_music =>@artist_music, :show_all=>true})}",
                :song_string      => "#{render_to_string('/artist_music/_song_item',:layout =>false, :locals =>{:song =>@song})}"
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
      logger.error "Error in ArtistArtistMusic#Create :=>#{exp.message}"
      render :nothing => true and return
    end
  end

  def add
    if request.xhr?
      begin
        @artist_music       = ArtistMusic.where(:album_name => params[:artist_music_name], :artist_id => @artist.id).first
        if @has_admin_access
          @song             = Song.new
          @has_link_access  = true
        else
          # render :nothing => true and return
        end
        render :action    => 'new', :format => 'js' and return
      rescue =>exp
        logger.error "Error in ArtistArtistMusic#Add :=> #{exp.message}"
        render :nothing   => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def artist_music_songs
    if request.xhr?
      begin        
        @artist_music = ArtistMusic.where('artist_id = ? and album_name = ?', @artist.id, params[:artist_music_name]).includes(:songs).first
      rescue
        render :nothing => true and return
      end
    else
      redirect_to show_artist_path(:artist_name => params[:artist_name]) and return
    end
  end

  # edit form for song album, renders the pop-up to change the image and upload more songs
  def edit_artist_music
    redirect_to show_artist_path(params[:artist_name]) and return unless request.xhr?
    begin
      if @has_admin_access
        @artist_music       = ArtistMusic.where('artist_id = ? and album_name = ?', @artist.id, params[:artist_music_name]).includes(:songs).first
        @has_link_access    = true
      else
        render :nothing => true and return
      end
    rescue =>exp
      logger.error "Error in ArtistArtistMusic::EditArtistMusic :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  # updates the song album, adding more songs, changing the cover image
  def update_artist_music
    begin
      if @has_admin_access
        @artist_music       = ArtistMusic.where('artist_id = ? and id = ?', @artist.id, params[:id]).first
        @artist_music.update_attributes(params[:artist_music])
        @is_updated         = true
        @has_link_access    = true
        render :action => 'edit_artist_music' and return
      else
        render :nothing => true and return
      end
    rescue =>exp
      logger.error "Error in ArtistArtistMusic#UpdateArtistMusic :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  def destroy_artist_music
    if request.xhr?
      begin
        @artist_music       = ArtistMusic.where(:id => params[:artist_music_id], :artist_id => @artist.id).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @status             = @artist_music.destroy
        @featured_songs     = @artist.featured_songs
      rescue =>exp
        logger.error "Error in ArtistArtistMusic#DestroyAritstMusic :=> #{exp.message}"
        @status             = false
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  def destroy_song
    if request.xhr?
      begin
        @song                 = Song.where(:id => params[:song_id]).first
        unless @has_admin_access
          render :nothing => true and return
        end
        @status               = @song.destroy
        @song.artist_music.decrease_song_count(@song)
        @is_featured          = @song.is_featured?
        if @is_featured
          @featured_songs     = @artist.featured_songs
        end
      rescue =>exp
        logger.error "Error in ArtistArtistMusic#DestroySong :=> #{exp.message}"
        @status         = false
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  # edit form for a single song, renders the pop-up to change the song title
  def edit_song
    if request.xhr?
      begin
        @song             = Song.find(params[:id])
        @is_updated       = false
        unless @has_admin_access
          render :nothing => true and return
        end
        @has_link_access  = true
      rescue =>exp
        logger.error "Error in ArtistArtistMusic#EditSong :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  # updates the single song detail
  def update_song
    if request.xhr?
      begin
        @song                   = Song.find(params[:id])
        if @has_admin_access
          @song.update_attributes(params[:song])
          @song.delay.update_metadata_to_file
          @is_updated           = true
          @has_link_access      = true
          render :action => 'edit_song' and return
        end
      rescue =>exp
        logger.error "Error in ArtistArtistMusic#UpdateSong :=> #{exp.message}"
        render :nothing => true and return
      end
    else
      redirect_to show_artist_url(params[:artist_name]) and return
    end
  end

  # requested artist music download
  def download_artist_music
    begin
      @artist_music            = ArtistMusic.find(params[:id])
      zipped_album             = @artist_music.songs_bundle(@artist_music.songs.processed)
      send_file zipped_album,  :disposition => 'inline'
    rescue =>exp
      logger.error "Error in ArtistArtistMusic#DownloadAlubm :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  # requested song download
  def download
    begin
      song                      = Song.find(params[:id])
      send_file song.song.path, :disposition => 'inline'
    rescue
      render :nothing => true and return
    end
  end

  # song like/dislike by current user
  def do_like_dislike_song
    actor                       = current_user
    begin
      @song                     = Song.find(params[:id])
      @should_like              = params[:do_like].present? && params[:do_like] == "1"
      if @should_like
        @song.liked_by(actor)
        @liked                  = 1
      else
        @song.disliked_by(actor)
        @liked                  = 0
      end
      render :text =>"{like:#{@liked}}" and return
    rescue =>exp
      logger.error "Error in ArtistArtistMusic::DoLikeSong :=> #{exp.message}"
      render :nothing => true and return
    end
  end

  def disable_enable_artist_music
    begin
      @artist                     = Artist.where(:name => params[:artist_name]).first
      if @has_admin_access
        @artist_music             = ArtistMusic.where('artist_id = ? and album_name = ?', @artist.id, params[:artist_music_name]).includes(:songs).first
      end
      if @artist_music
        @artist_music.update_attribute(:disabled,!@artist_music.disabled)
      end
    rescue
      render :nothing => true and return
    end
  end

  # lists artist's song albums to choose from for setting as featured album
  def albums_for_featured_list
    begin      
      @artist_musics      = @artist.artist_musics.where('featured is false')
      @status             = true
    rescue
      @status             = false
    end
    render :layout =>false
  end

  # sets the requested song album as featured album
  def make_artist_music_featured
    begin
      if @has_amdin_access
        @artist_music       = ArtistMusic.where('artist_id = ? and album_name = ?', @artist.id, params[:artist_music_name]).first
      end
      if @artist_music
        @artist_music.update_attribute(:featured, !@artist_music.featured)
        @status = true
      end
    rescue
      @status   = false
    end
  end

  # lists artist's song album and songs to choose from for setting as featured
  def songs_for_featured_list
    begin
      @artist_musics        = @artist.artist_musics.includes('songs')
      @status               = true
      @has_link_access      = true
    rescue => exp
      logger.error "Error in ArtistArtistMusic::SongsForFeaturedList :=>#{exp.message}"
      @status               = false
    end
    render :layout =>false
  end

  # sets the requested song as featured song
  def make_song_featured
    begin
      if @has_admin_access
        begin @song       = Song.find params[:id] rescue @song = nil end
        @song.update_attribute(:is_featured, !@song.is_featured) if @song
        @status           = true
        @featured_songs   = @artist.featured_songs
      end
    rescue =>exp
      logger.error "Error in ArtistArtistMusic#MakeSongFeatured :=> #{exp.message}"
      @status   = false
    end
  end

  private

  def coerce(params)
    if params[:song].nil?
      h                             = Hash.new
      h[:song]                      = Hash.new
      h[:song][:song]               = params[:Filedata]
      h[:song][:song].content_type  = MIME::Types.type_for(h[:song][:song].original_filename).to_s
      h
    else
      params
    end
  end  

  # finds the artist profile by artist_name parameter, and checks whether the current login is artist or fan
  # and accordingly sets the variable @has_admin_access to be used in views and other actions
  def check_and_set_admin_access    
    begin
      if params[:artist_name] == 'home'
        @artist           = @actor
        @has_admin_access = @artist == @actor
        @has_link_access  = @has_admin_access
      else
        @artist           = Artist.where(:mention_name => params[:artist_name]).first
        @has_admin_access = @artist == @actor
        @is_public        = true
        @has_link_access  = false
      end
    rescue
      @artist             = nil
    end
    unless @artist
      render :template =>"bricks/page_missing" and return
    end
  end

end
