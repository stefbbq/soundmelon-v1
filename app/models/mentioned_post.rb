require 'activerecord-import'

class MentionedPost < ActiveRecord::Base  
  belongs_to :user
  belongs_to :artist
  belongs_to :post
  belongs_to :mentionitem, :polymorphic =>true
  
  def self.create_post_mentions(post, mentioned_items)
    mentioned_posts = []
    actor           = post.writer_actor    
    mentioned_items.each do |mentioned_item|
      mentioned_posts << mentioned_item.mentioned_posts.build(:post_id => post.id, :mentionitem_name =>mentioned_item.mention_name, :status => UNREAD)
      NotificationMail.mention_notification mentioned_item, actor, post if actor
    end        
    self.import mentioned_posts    
  end

end