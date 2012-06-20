class Feedback < ActiveRecord::Base
  
  validates :feedback_topic_id, :presence =>true, :numericality =>true
  validates :content, :presence =>true
  
  belongs_to :feedback_topic
  belongs_to :user

  after_create :set_to_deliver_notification

  scope :recent_feedbacks, :conditions =>["is_read is false and created_at > ?",  Time.now - 15.days ]

  def set_to_deliver_notification
    self.delay.send_notification
  end

  def send_notification
    topic = self.feedback_topic
    if topic
      emails = topic.emails.blank? ? [] : topic.emails.split(';')
    end
    begin
      user = self.user_type.constantize.find(self.user_id)
    rescue
      user = nil
    end
    begin      
      emails.each{|email|
        UserMailer.feedback_notification_email(self, topic, user).deliver
      }
    rescue =>exp
      logger.error "Error Feedback::SendNotification :=>#{exp.message} "
    end
  end
  

end
