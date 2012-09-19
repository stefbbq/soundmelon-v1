class ColonyController < ApplicationController
  before_filter :require_login
  before_filter :setup_colony, :only =>[:show, :join, :member]
  
  layout 'layouts/popup', :only =>[:new, :create, :setup_profile]
  layout 'layouts/application', :only =>[:show]

  def new
    @user                   = current_user
    session[:colony_params] = {}
    session[:colony_step]   = nil
    @colony                 = Colony.new(session[:colony_params])
    @colony.current_step    = session[:colony_step]
    #    get_user_associated_objects
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
              @colony.member    = @actor
              @colony.is_admin  = true
              @colony.approved  = true
              @colony.save
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
        render "new" and return
      else
        session[:colony_step] = session[:colony_params] = nil
        flash[:notice]        = "New colony profile created"        
        render 'setup_profile' and return
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
    end
  end

  def show
    begin      
      @posts        = @colony.posts
      @posts_order_by_dates      = @posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    rescue =>exp      
      logger.error "Error in Colony::Show :=> #{exp.message}"
    end
  end

  def update
  end

  def join
    begin      
      @colony.add_member(@actor, false, true)
    rescue =>exp
      logger.error "Error in Colony::Join :=> #{exp.message}"
    end
  end

  def members
    @members = @colony.members
  end

  protected

  def setup_colony
    begin
      @colony       = Colony.find(params[:id])
    rescue =>exp
      logger.error "Error in Colony::SetupColony :=> #{exp.message}"
    end
  end

end
