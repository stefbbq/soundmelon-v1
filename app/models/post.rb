class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :artist
  belongs_to :postitem, :polymorphic =>true
  has_many :mentioned_posts
  has_ancestry :orphan_strategy =>:rootify
  before_save :update_mentioned_actors_in_post
  after_save :check_and_save_mentioned_in_post
  
  # default its being called from current user wall. If current user is replying as a artist then second argument would be false  
  def owner_as_well_as_all_mentioned_users_and_artists_except(user_or_artist_id, user = true)
    participating_users_and_artists = []
    if user && !self.user_id.blank? && user_or_artist_id != self.user_id 
      participating_users_and_artists << self.user.mention_name
    elsif !user && !self.artist_id.blank? && !user_or_artist_id == self.artist_id  
      participating_users_and_artists << self.artist.mention_name
    elsif !user && !self.user.nil?
      participating_users_and_artists << self.user.mention_name
    elsif user && !self.artist.nil?
      participating_users_and_artists << self.artist.mention_name
    end
    
    self.mentioned_posts.each do |mentioned_post|
      if !mentioned_post.user_id.blank?
        if user
          if !mentioned_post.user.nil? && mentioned_post.user_id != user_or_artist_id
            participating_users_and_artists << mentioned_post.user.mention_name
          end
        else
          participating_users_and_artists << mentioned_post.artist.mention_name unless mentioned_post.artist.nil?
        end
      elsif !mentioned_post.artist_id.blank?
        if !user
          if !mentioned_post.artist.nil? && mentioned_post.artist_id != user_or_artist_id
            participating_users_and_artists << mentioned_post.artist.mention_name
          end
        else
          participating_users_and_artists << mentioned_post.user.mention_name unless mentioned_post.user.nil?
        end
      end
    end
    return participating_users_and_artists 
  end  

  def self.create_post_for item, actor, params
    user_id, artist_id = actor.is_fan? ? [actor.id, nil] : [nil, actor.id]    
    post_item = create(
      :postitem_type  => item.class.name,
      :postitem_id    => item.id,
      :user_id        => user_id,
      :artist_id      => artist_id,
      :msg            => params[:msg]
    )
    post_item.delay.create_notification_email_for_post(actor, item)
    post_item
  end

  def self.posts_for item, limit = 20, page=1
    where(:postitem_type => item.class.name, :postitem_id => item.id, :is_newsfeed =>false).order('created_at desc').limit(limit).page(page)
  end

  def self.create_newsfeed_for item, user_id, artist_id, msg
    last_post = self.find_or_create_by_postitem_type_and_postitem_id(item.class.name, item.id)
    last_post.update_attributes(      
      :user_id        => user_id,
      :artist_id      => artist_id,
      :is_newsfeed    => true,
      :msg            => msg
    )
  end

  def has_post_item?
    !self.postitem
  end
  
  def artist_photo_post?
    postitem_type == 'ArtistPhoto'
  end

  def artist_album_post?
    postitem_type == 'ArtistAlbum'
  end

  def artist_music_post?
    postitem_type == 'ArtistMusic'
  end

  def song_post?
    postitem_type == 'Song'
  end

  def artist_show_post?
    postitem_type == 'ArtistShow'
  end

  def create_notification_email_for_post actor, post_item = self.postitem
    notice_receivers          = []    
    if post_item      
      artist                  = post_item.artist
      if self.artist_id != artist.id  # posted by artist itself
        artist_admin_users    = artist.artist_admin_users                
        notice_receivers      = artist_admin_users - [self.user] # do not send notification to writer fan user
      end
      unless notice_receivers.blank?
        # send notification
        notice_receivers.each{|user|
          NotificationMail.buzz_notification user, actor, post_item, self
        }
      end
    end    
  end
  
  def writer_actor
    if artist_id.blank?
      self.user
    else
      self.artist
    end
  end

  protected

  def update_mentioned_actors_in_post    
    if self.msg =~/@\w/      
      splitted_post_msg       = self.msg.split(" ").map{|aa| "@#{aa.gsub(/[^0-9A-Za-z]/, '')}"}
      splitted_post_msg       = splitted_post_msg.map{|aa| aa.gsub('@', '')}
      mentioned_artists       = Artist.find_artists_in_mentioned_post(splitted_post_msg)
      mentioned_users         = User.find_users_in_mentioned_post(splitted_post_msg)
      self.mentioned_users    = mentioned_users.map{|mu| [mu.id,mu.mention_name]}.join(',')
      self.mentioned_artists  = mentioned_artists.map{|mb| mb.mention_name}.join(',')      
    end
  end

  def check_and_save_mentioned_in_post
    if self.msg =~/@\w/
      splitted_post_msg       = self.msg.split(" ").map{|aa| "@#{aa.gsub(/[^0-9A-Za-z]/, '')}"}
      splitted_post_msg       = splitted_post_msg.map{|aa| aa.gsub('@', '')}
      mentioned_artists       = Artist.find_artists_in_mentioned_post(splitted_post_msg)
      mentioned_users         = User.find_users_in_mentioned_post(splitted_post_msg)
      MentionedPost.create_post_mentions(self, mentioned_users, mentioned_artists)
    end
  end
end