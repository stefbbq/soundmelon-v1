class ColonyController < ApplicationController
  before_filter :require_login
  before_filter :setup_colony, :only =>[:show, :join, :unjoin, :members, :edit, :update]
  #  layout 'popup', :except =>[:show, :join, :members]

  def new
    @user                   = current_user
    session[:colony_params] = {}
    session[:colony_step]   = nil
    @colony                 = Colony.new(session[:colony_params])
    @colony.current_step    = session[:colony_step]    
    render :layout =>'popup'
  end

  def create
    if request.post?
      begin
        session[:colony_params]   ||= {}
        session[:colony_params].deep_merge!(params[:colony]) if params[:colony]
        @colony                   = Colony.new(session[:colony_params])
        @colony.current_step      = session[:colony_step]
        if @colony.valid?
          if params[:back_button]
            @colony.previous_step
          elsif @colony.last_step?
            if @colony.all_valid? && @colony.save
              @cm           = @colony.colony_memberships.build
              @cm.member    = @actor
              @cm.is_admin  = true
              @cm.approved  = true
              @cm.save
            end
          else
            @colony.next_step
          end
          session[:colony_step]     = @colony.current_step
        end
      rescue =>excp
        logger.error "Error in Colony::Create :#{excp.message}"
      end

      if @colony.new_record?
        render "new", :layout =>'popup' and return
      else
        session[:colony_step] = session[:colony_params] = nil
        flash[:notice]        = "New colony profile created"        
        render 'setup_profile', :layout =>'popup' and return
      end
    end    
  end

  def setup_profile
    begin
      @colony             = Colony.find params[:id]      
    rescue =>excp
      logger.error "Error in Colony::SetupProfile :=>#{excp.message}"
    end
    unless request.get?      
      current_setup_step = params[:setup_step].present? ? params[:setup_step].to_i : 0
      case current_setup_step
      when 1        
        @colony.update_attributes(params[:colony])
        @followings         = current_user.all_following
        @followings.each do |following|
          @colony.colony_memberships.build(:member =>following)
        end
        @colony_setup_step  = 2
      when 2
        @colony.update_attributes(params[:colony])
        @colony_setup_step  = 3      
      end
    else
      render :layout =>'popup'
    end
  end

  def show
    begin      
      setup_colony_posts_set(@colony)
      check_and_membership_status(@colony)
    rescue =>exp      
      logger.error "Error in Colony::Show :=> #{exp.message}"
    end
  end

  def update    
    if @colony.update_attributes(params[:colony])
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js {render :action => 'edit' and return}
      end
    end
  end

  def join
    begin      
      @membership           = @colony.add_member(@actor, false, true)
      @is_admin             = @membership.is_admin_membership?
      setup_colony_posts_set(@colony)
    rescue =>exp
      logger.error "Error in Colony::Join :=> #{exp.message}"
    end
  end

  def unjoin
    begin
      @colony.remove_member @actor
      @is_admin             = false
      setup_colony_posts_set(@colony)
    rescue =>exp
      logger.error "Error in Colony::Unjoin :=> #{exp.message}"
    end
  end
  
  def members
    @members = @colony.members
  end

  def more_posts
    setup_colony
    setup_colony_posts_set(@colony)
    render :template =>'/user_posts/more_posts'
  end

  protected
  
  def setup_colony
    begin
      @colony       = Colony.find(params[:id])      
    rescue =>exp      
      logger.error "Error in Colony::SetupColony :=> #{exp.message}"
    end
  end

  def setup_colony_posts_set colony
    @posts                 = @colony.all_posts params[:page]
    @posts_order_by_dates  = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    next_page              = @posts.next_page
    @load_more_path        = next_page ? colony_more_posts_path(colony.id, next_page) : nil
  end

  def check_and_membership_status colony
    cm         = ColonyMembership.for_item_and_colony(@actor, colony)
    @is_member = !cm.blank?
    @is_admin  = @is_member && cm.first.is_admin_membership?    
  end

end