class AvatarController < ApplicationController
  before_filter :require_login
  before_filter :set_actor_and_entities, :only =>[:new, :create, :crop, :edit, :update, :delete]
  before_filter :set_actor_and_profile_banner, :only =>[:new_banner, :create_banner, :crop_banner, :edit_banner, :update_banner, :delete_banner]

  def new
    begin      
      @profile_pic = @item.build_profile_pic
    rescue =>exp
      logger.error "Error in Avatar::New :=> #{exp.message}"
      render :nothing =>true and return
    end
    respond_to do |format|
      format.js
    end
  end

  def create
    begin
      params[:profile_pic][:profileitem_type] = @item.class.name
      params[:profile_pic][:profileitem_id]   = @item.id
      @profile_pic  = @item.build_profile_pic(params[:profile_pic])
    rescue =>exp
      logger.error "Error: #{exp.message}"
      @item         = nil
    end
    respond_to do |format|
      if @profile_pic.save
        @original_geometry = @profile_pic.avatar_geometry(:original)
        set_height_and_width @original_geometry
        format.js { render :action => 'crop' and return }
      else
        format.js { render :action => 'new' and return}
      end
    end
  end

  def edit    
  end

  def update    
    if @profile_pic.update_attributes(params[:profile_pic])
      respond_to do |format|
        format.js
      end
    end
  end

  def crop
    @ratio = @profile_pic.avatar_geometry(:original).width / @profile_pic.avatar_geometry(:original).height
    @original_geometry = @profile_pic.avatar_geometry(:original)
    set_height_and_width @original_geometry
  end

  def delete    
    redirect_to fan_home_url and return unless @profile_pic
    if @profile_pic.delete
      respond_to do |format|
        format.js
      end
    end
  end

  # profile banner image
  def new_banner
    begin
      @profile_banner = @item.build_profile_banner
    rescue =>exp
      logger.error "Error in Avatar::NewBanner :=> #{exp.message}"
      render :nothing =>true and return
    end
    respond_to do |format|
      format.js
    end
  end

  def create_banner
    begin
      params[:profile_banner][:profileitem_type] = @item.class.name
      params[:profile_banner][:profileitem_id]   = @item.id
      @profile_banner  = @item.build_profile_banner(params[:profile_banner])
    rescue =>exp
      logger.error "Error: #{exp.message}"
      @item = nil
    end
    respond_to do |format|
      if @profile_banner.save
        @original_geometry = @profile_banner.image_geometry(:original)
        set_height_and_width @original_geometry
        format.js { render :action => 'crop_banner' and return }
      else
        format.js { render :action => 'new_banner' and return}
      end
    end
  end

  def edit_banner
  end

  def update_banner
    if @profile_banner.update_attributes(params[:profile_banner])
      respond_to do |format|
        format.js
      end
    end
  end

  def crop_banner
    @ratio = @profile_banner.avatar_geometry(:original).width / @profile_banner.avatar_geometry(:original).height
    @original_geometry = @profile_banner.avatar_geometry(:original)
    set_height_and_width @original_geometry
  end

  def delete_banner
    redirect_to fan_home_url and return unless @profile_banner
    if @profile_banner.delete
      respond_to do |format|
        format.js
      end
    end
  end


  private

  def set_actor_and_entities
    if request.xhr?
      begin
        @actor = current_actor
        @item           = @actor
        @profile_pic    = @actor.profile_pic
      rescue =>exp
        logger.error "Error in Avatar::SetActorAndEntities :=> #{exp.message}"
      end
    else
      render :template =>'/bricks/page_missing'
    end
  end

  def set_actor_and_profile_banner
    if request.xhr?
      begin
        @actor          = current_actor
        @item           = @actor
        @profile_banner = @actor.profile_banner
      rescue =>exp
        logger.error "Error in Avatar::SetActorAndBanner :=> #{exp.message}"
      end
    else
      render :template =>'/bricks/page_missing'
    end
  end


  def set_height_and_width geometry    
    img_height      = 400
    img_width       = 400
    height          = geometry.height
    width           = geometry.width
    @show_height    = height > img_height ? img_height : height
    @show_width     = width > img_width ? img_width : width
    @height_change  = (height/img_height)
    @width_change   = (width/img_width)
    @is_cropping    = false
  end

end
