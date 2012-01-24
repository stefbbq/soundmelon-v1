class MessagesController < ApplicationController
  before_filter :require_login
  
  def send_message
    @to_user = User.find(params[:receiver_id])
    current_user.send_message(@to_user,{:body=>params[:message_text]})
  end
  
  def inbox
    @user = current_user
    @messages = current_user.received_messages.reverse  
  end
  
  
  def index
    @messages = current_user.received_messages
    redirect_to "inbox"
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
