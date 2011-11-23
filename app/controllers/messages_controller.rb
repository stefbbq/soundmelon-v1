class MessagesController < ApplicationController
  before_filter :require_login
  
  
  
  def send_message
    @to_user = User.find(params[:receiver_id])
    current_user.send_message(@to_user,{:body=>params[:message_text]})
  end
  
  def inbox
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
    @message = current_user.messages.with_id(params[:id]).first
    @message.update_attribute("opened",true)
    @messages = @message.conversation
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
     if current_user.id == @msg.sent_messageable_id || current_user.id == @msg.received_messageable_id
       current_user.reply_to(@msg,:body=>params[:body])
     else
      # render :nothing => true and return
     end
   rescue ActiveRecord::RecordNotFound
     #render :nothing => true and return
   end
    @message = @msg
    @messages = @message.conversation
    
 end
  
  
end
