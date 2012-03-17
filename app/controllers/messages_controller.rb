class MessagesController < ApplicationController
  before_filter :require_login
  
  def send_message
    @to_user = User.find(params[:receiver_id])
    current_user.send_message(@to_user,{:body=>params[:message_text]})
  end
  
  def inbox
    begin
      @user = current_user
      if params[:band_name]
        
        @band = Band.where(:name => params[:band_name]).first
        unless request.xhr?
          redirect_to show_band_url(:band_name => @band.name) and return 
        end
        if current_user.is_admin_of_band?(@band)
          @unread_mentioned_count = @band.unread_mentioned_post_count
          @unread_post_replies_count = @band.unread_post_replies_count
          @unread_messages_count = @band.received_messages.unread.count
          @messages = @band.inbox(params[:page])  
        else
          @messages = []
          next_page = nil
        end
      else
        get_user_associated_objects
        #TODO: not get called automatically so calling explicitly. Need to investigate
        messages_and_posts_count 
        @messages = current_user.inbox(params[:page])
      end
      next_page ||= @messages.next_page
      if @band
        @load_more_path =  next_page ?  more_inbox_messages_path(:band_name => @band.name, :page => next_page) : nil
      else
        @load_more_path =  next_page ?  more_inbox_messages_path(:page => next_page) : nil
      end
    rescue
      render :nothing => true
    end
  end
  
  
  def index
    redirect_to inbox_url and return unless request.xhr?
    if params[:band_name]
        band = Band.where(:name => params[:band_name]).first
        if current_user.is_admin_of_band?(band)
          @messages = band.inbox(params[:page])
        else
          @messages = []
          next_page = nil
        end
      else
        @messages = current_user.inbox(params[:page])
      end
      next_page ||= @messages.next_page
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
    begin
      if params[:band_id].present?
        @band = Band.where(:id => params[:band_id]).first
        raise unless current_user.is_admin_of_band?(@band)
        @message = @band.messages.with_id(params[:id]).first  
      else
        @message = current_user.messages.with_id(params[:id]).first
      end
      @message.update_attribute("opened",true)
      @messages = @message.conversation
    rescue
      render :nothing => true
    end
  end

  def destroy
    @message = current_user.messages.with_id(params[:id]).first
    @message.update_attribute("opened",true)
    if @message.destroy
      @deleted = true
    else
      @deleted = false
    end
  end

  def new
    @to = params[:id] 
    @message = ActsAsMessageable::Message.new
  end

  def create
    to = User.find(params[:to])
    current_user.send_message(to,params[:body])
  end
  
 def reply
   begin
     @msg = ActsAsMessageable::Message.find(params[:id])
     if params[:band_id].present?
       band = Band.where(:id => params[:band_id]).first
       raise unless current_user.is_admin_of_band?(band)
       if band.id == @msg.sent_messageable_id || band.id == @msg.received_messageable_id
         band.reply_to(@msg,:body=>params[:body])
       end
     else current_user.id == @msg.sent_messageable_id || current_user.id == @msg.received_messageable_id
       current_user.reply_to(@msg,:body=>params[:body])
     end
   rescue 
     render :nothing => true and return
   end
   @message = @msg
   @messages = @message.conversation
 end
  
end