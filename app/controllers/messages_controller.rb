class MessagesController < ApplicationController
  before_filter :require_login

  def send_message
    redirect_to root_url and return unless request.xhr?
    @to_user    = User.find(params[:receiver_id])
    current_user.send_message(@to_user,{:body=>params[:message_text]})
  end

  def inbox
    begin
      @from_header_link = params[:top].present?
      @user             = current_actor
      messages_and_posts_count
      @is_homepage      = true
      if @user.is_fan?
        get_user_associated_objects #unless @from_header_link
        #TODO: not get called automatically so calling explicitly. Need to investigate        
      elsif @user.is_artist?
        @artist                       = @user        
        get_artist_objects_for_right_column(@artist) #unless @from_header_link
      elsif @user.is_venue?
        @venue                        = @user
        get_venue_objects_for_right_column(@venue) #unless @from_header_link
      end
      @messages                 = @user.mailbox.conversations.page(params[:page]).per(MESSAGES_PER_PAGE).includes(:receipts, :messages)
      num_pages                 = @messages.num_pages
      current_page              = @messages.current_page
      next_page                 = current_page < num_pages ? current_page + 1 : nil
      @load_more_path           = next_page ?  more_inbox_messages_path(:page => next_page) : nil
      @has_link_access          = true
    rescue =>exp
      logger.error "Error in Messages::Inbox =>#{exp.message}"
      render :nothing => true
    end
  end
  
  def index
    redirect_to inbox_url and return unless request.xhr?
    @user = current_actor
    @messages         = @user.mailbox.conversations.page(params[:page]).per(MESSAGES_PER_PAGE).includes(:receipts, :messages)
    num_pages         = @messages.num_pages
    current_page      = @messages.current_page
    next_page         = current_page < num_pages ? current_page + 1 : nil
    @load_more_path   =  next_page ?  more_inbox_messages_path(:page => next_page) : nil
    @has_link_access  = true
  end

  def show
    redirect_to root_url and return unless request.xhr?
    begin
      @actor           = current_actor
      @message         = Message.find(params[:id])
      if @message
        @receipt       = @message.receipt_for(@actor).first
        @receipt.mark_as_read if @receipt
      end
    rescue =>exp
      logger.info "Error in Messages::Show :=> #{exp.message}"
      render :nothing => true
    end
  end

  def show_conversation_thread
    @user                  = current_actor
    @conversation          = Conversation.find(params[:conversation_id])
    @conversation_receipts = @conversation.receipts_for(@user).not_trash.order('created_at desc')    
  end

  def destroy
    redirect_to root_url and return unless request.xhr?
    begin
      @actor                = current_actor
      @message              = Message.find params[:id]
      if @message
        @receipt            = @message.receipt_for(@actor).first
        @conversation       = @receipt.conversation
        @deleted            = @receipt.move_to_trash
        @empty_conversation = @conversation.receipts_for(@actor).not_trash.empty?
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
    begin
      @user        = current_actor
      to_user       = User.find(params[:to])      
      receipt       = @user.send_message(to_user, params[:body], 'Subject')
      NotificationMail.message_notification(to_user, @user, receipt.message) if receipt
    rescue =>exp
      logger.error "Error in Messages::Create :#{exp.message}"
    end
  end
  
  def reply
    redirect_to root_url and return unless request.xhr?
    begin
      @user         = current_actor
      @conversation  = Conversation.find(params[:id])
      @new_message   = @user.reply_to_conversation(@conversation, params[:body]).message
      if @new_message
        to_user        = @conversation.participants.delete_if{|p| p.id == @user.id and p.class.name == @user.class.name}.first
        NotificationMail.message_notification(to_user, @user, @new_message)
      end
    rescue =>exp
      logger.error "Error in Messages::Reply :=> #{exp.message}"
      render :nothing => true and return
    end
  end
  
end