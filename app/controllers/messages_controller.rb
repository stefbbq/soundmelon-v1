class MessagesController < ApplicationController
  before_filter :require_login
  
  def send_message
    redirect_to root_url and return unless request.xhr?
    @to_user    = User.find(params[:receiver_id])
    current_user.send_message(@to_user,{:body=>params[:message_text]})
  end
  
  def inbox
    begin      
      @user = current_actor
      if @user.is_fan?
        get_user_associated_objects
        #TODO: not get called automatically so calling explicitly. Need to investigate
        messages_and_posts_count
        @messages = current_user.inbox(params[:page])        
      else
        @band                       = @user        
        @unread_mentioned_count     = @band.unread_mentioned_post_count
        @unread_post_replies_count  = @band.unread_post_replies_count
        @unread_messages_count      = @band.received_messages.unread.count
        @messages                   = @band.inbox(params[:page])
        get_artist_objects_for_right_column(@band) #unless request.xhr?
      end
      next_page ||= @messages.next_page      
      @load_more_path =  next_page ?  more_inbox_messages_path(:page => next_page) : nil
    rescue
      render :nothing => true
    end
  end
  
  def index
    redirect_to inbox_url and return unless request.xhr?
    if params[:band_name]
        band        = Band.where(:name => params[:band_name]).first
        if current_user.is_admin_of_band?(band)
          @messages = band.inbox(params[:page])
        else
          @messages = []
          next_page = nil
        end
      else
        @messages   = current_user.inbox(params[:page])
      end
      next_page   ||= @messages.next_page
      if band
        @load_more_path =  next_page ?  more_inbox_messages_path(:band_name => band.name, :page => next_page) : nil
      else
        @load_more_path =  next_page ?  more_inbox_messages_path(:page => next_page) : nil
      end
  end

  def outbox
    @messages = current_user.sent_messages
  end

  def show
    redirect_to root_url and return unless request.xhr?
    begin
      @actor                        = current_actor
      @message                      = @actor.messages.with_id(params[:id]).first
      if @message
        @message.update_attribute("opened",true)
        @messages                   = @message.conversation
        @unread_messages_count      = @actor.received_messages.unread.count
#        messages_and_posts_count
      end
    rescue =>e
      logger.info "message error: #{e.message}"
      render :nothing => true
    end
  end

  def destroy
    redirect_to root_url and return unless request.xhr?
    begin
      @actor        = current_actor
      @message      = @actor.messages.with_id(params[:id]).first      
      if @message
        @deleted    = @message.destroy
      else
        @deleted    = false
      end
    rescue =>exp
      logger.info "Error in Messages::Destroy :=> #{exp.message}"
      render :nothing => true
    end    
  end

  def new
    redirect_to root_url and return unless request.xhr?
    redirect_to user_profile_url(params[:id]) and return unless request.xhr?
    @to             = params[:id]
    @message        = ActsAsMessageable::Message.new
  end

  def create
    to              = User.find(params[:to])
    current_user.send_message(to, params[:body])
  end
  
 def reply
   redirect_to root_url and return unless request.xhr?
   begin
     @message       = ActsAsMessageable::Message.find(params[:id])
     @actor         = current_actor
     @reply_msg     = @actor.reply_to(@message,:body=>params[:body])     
     @messages      = @message.conversation
   rescue =>exp
     logger.error "Error in Messages::Reply :=> #{exp.message}"
     render :nothing => true and return
   end   
 end
  
end