class NotificationMail

  SUBJECT_FOLLOW_NOTIFICATION             = "You have a new follower on SoundMelon"
  SUBJECT_CONNECT_NOTIFICATION            = "You have a new connection request"
  SUBJECT_MESSAGE_NOTIFICATION            = "You have a new message"
  SUBJECT_MENTION_NOTIFICATION            = "Someone has mentioned you"
  SUBJECT_REPLY_NOTIFICATION              = "Someone has sent you a reply"
  SUBJECT_SONG_BUZZ_NOTIFICATION          = "Someone has written about your song"
  SUBJECT_SONG_ALBUM_BUZZ_NOTIFICATION    = "Someone has written about your music album"
  SUBJECT_PHOTO_ALBUM_BUZZ_NOTIFICATION   = "Someone has written about your photo album"
  SUBJECT_PHOTO_BUZZ_NOTIFICATION         = "Someone has written about your photo"
  NOTIFICATION_TYPES                      = ['follow', 'connect','connect_request', 'message', 'reply', 'mention', 'buzz']
  
  def self.follow_notification recipient_object, actor_object
    if recipient_object.is_fan?      
      subject         = "#{actor_object.get_name} has started to follow you on SoundMelon"
      action_item     = nil
    elsif recipient_object.is_artist?
      subject         = "#{actor_object.get_name} has started to follow your artist  #{recipient_object.get_name} on SoundMelon"
      action_item     = recipient_object
    elsif recipient_object.is_venue?
      subject         = "#{actor_object.get_name} has started to follow your venue #{recipient_object.get_name} on SoundMelon"
      action_item     = recipient_object
    end
    recipient_users   = self.get_notification_recipient_users recipient_object
    notification_type = 'follow'
    recipient_users.each{|user|
      NotificationMail.queue_notification_email(notification_type, subject, user, actor_object, action_item, nil)
    }    
  end

  def self.connect_notification recipient_object, actor_object
    notification_type = 'connect'
    subject           = "#{actor_object.get_name} has accpeted your connect request on SoundMelon"
    recipient_users   = self.get_notification_recipient_users recipient_object
    recipient_users.each{|user|
      NotificationMail.queue_notification_email(notification_type, subject, user, actor_object, recipient_object, nil)
    }
  end

  def self.connect_request_notification recipient_object, actor_object
    notification_type = 'connect_request'
    subject           = "#{actor_object.get_name} has sent a connect request to your artist #{recipient_object.get_name} on SoundMelon"
    recipient_users   = self.get_notification_recipient_users recipient_object
    recipient_users.each{|user|
      NotificationMail.queue_notification_email(notification_type, subject, user, actor_object, recipient_object, nil)
    }
  end

  def self.message_notification recipient_object, actor_object, message
    if recipient_object.is_fan?      
      subject         = "#{actor_object.get_name} has sent you a message on SoundMelon"
      action_item     = nil
    elsif recipient_object.is_artist?
      subject         = "#{actor_object.get_name} has sent a message to your artist #{recipient_object.get_name} on SoundMelon"
      action_item     = recipient_object
    elsif recipient_object.is_a?
      subject         = "#{actor_object.get_name} has sent a message to your venue #{recipient_object.get_name} on SoundMelon"
      action_item     = recipient_object
    end
    notification_type = 'message'
    recipient_users   = self.get_notification_recipient_users recipient_object
    content_item      = message
    recipient_users.each{|user|
      NotificationMail.queue_notification_email(notification_type, subject, user, actor_object, action_item, content_item)
    }
  end

  def self.buzz_notification recipient_user, actor_user, buzz_item, buzz
    notification_type = 'buzz'
    subject           = "#{actor_user.get_name} has buzzed on your #{buzz_item.useritem.class.name.downcase} item on SoundMelon"
    NotificationMail.queue_notification_email(notification_type, subject, recipient_user, actor_user, buzz_item, buzz)
  end

  def self.reply_notification recipient_object, actor_object, reply_message
    if recipient_object.is_fan?
      subject         = "#{actor_object.get_name} has replied you on SoundMelon"
      action_item     = nil
    elsif recipient_object.is_artist?
      subject         = "#{actor_object.get_name} has replied to your artist  #{recipient_object.get_name} on SoundMelon"
      action_item     = recipient_object
    elsif recipient_object.is_artist?
      subject         = "#{actor_object.get_name} has replied to your venue  #{recipient_object.get_name} on SoundMelon"
      action_item     = recipient_object
    end
    notification_type = 'reply'
    content_item      = reply_message
    recipient_users   = self.get_notification_recipient_users recipient_object
    recipient_users.each{|user|
      NotificationMail.queue_notification_email(notification_type, subject, user, actor_object, action_item, content_item)
    }
  end 

  def self.mention_notification recipient_object, actor_object, mention_post
    if recipient_object.is_fan?
      subject         = "#{actor_object.get_name} has mentioned you in a post on SoundMelon"
      action_item     = nil
    elsif recipient_object.is_artist?
      subject         = "#{actor_object.get_name} has mentioned your artist #{recipient_object.get_name} in a post on SoundMelon"
      action_item     = recipient_object
    elsif  recipient_object.is_venue?
      subject         = "#{actor_object.get_name} has mentioned your venue #{recipient_object.get_name} in a post on SoundMelon"
      action_item     = recipient_object
    end
    notification_type = 'mention'    
    content_item      = mention_post
    recipient_users   = self.get_notification_recipient_users recipient_object
    recipient_users.each{|user|
      NotificationMail.queue_notification_email(notification_type, subject, user, actor_object, action_item, content_item)
    }
  end
    
  def self.queue_notification_email  notification_type, subject, recipient_user, actor_user, action_item, content_item
#    UserMailer.delay.general_notification_email(notification_type, subject, recipient_user, actor_user, action_item, content_item)
    UserMailer.general_notification_email(notification_type, subject, recipient_user, actor_user, action_item, content_item).deliver unless Rails.env=='development'
  end

  # collects the users to be notified based on their setting for email notification
  def self.get_notification_recipient_users recipient_object    
    recipient_users   = []
    if recipient_object.is_fan?
      recipient_users << recipient_object if recipient_object.notification_on?
    elsif recipient_object.is_artist?
      recipient_users = recipient_object.artist_notified_users
    elsif  recipient_object.is_venue?
      recipient_users = recipient_object.venue_notified_users
    end
    recipient_users
  end
  
end
