module UserEntity
  
  def self.included(base)
    base.extend ClassMethods    
  end

  module ClassMethods

    def find_in_mentioned_post mentioned_name_arr
      return self.where(:mention_name => mentioned_name_arr).select('DISTINCT(id), mention_name').all
    end

    def suggested_items input_params      
      location_name = input_params[:location_name]
      item_name     = input_params[:name]
      items_ids     = input_params[:id]
      self.where("id in (?) or name like '%?%'", items_ids, item_name)
    end
    
  end
      
  def is_fan?
    self.instance_of? User
  end

  def is_artist?
    self.instance_of? Artist
  end

  def is_venue?
    self.instance_of? Venue
  end

  def get_name
    self.get_full_name
  end

  def get_location
    location    = ''
    if self.is_fan? or self.is_artist?
       location  = self.address
    elsif self.is_venue?
      location  = self.location
    end
    location
  end

  # artist connections
  # has made request to connect with artist
  def connection_requested_for? item
    UserItemConnection.connection_requested? self, item
  end

  def connected_with? item
    UserItemConnection.connected?(self, item)
  end

  def connected_artists page = 1
    UserItemConnection.connected_artists_with self, page
  end

  def connected_venues page = 1
    UserItemConnection.connected_artists_with self, page
  end

  def connections_count
    UserItemConnection.connection_count_for self
  end

  def connect_artist artist
    UserItemConnection.add_connection_between self, artist
  end

  def connect_venue venue
    UserItemConnection.add_connection_between self, venue
  end  

  def disconnect_artist artist
    UserItemConnection.remove_connection_between self, artist
  end

  def connection_requests
    UserItemConnection.requested_connections_for self
  end

  def add_favorite_venues venues
    fav_venues_limit    = 3
    existing_fav_venues = self.favorite_items.for_venues.map(&:favoreditem)
    new_venues          = venues - existing_fav_venues
    existing_fav_count  = existing_fav_venues.size
    new_venues.each do |v|
      fav_item = self.favorite_items.build
      fav_item.favoreditem = v
      fav_item.save
    end
  end

  def add_favorite_artists artists
    fav_artists_limit     = 3
    existing_fav_artists  = self.favorite_items.for_artists.map(&:favoreditem)
    new_artists           = artists - existing_fav_artists
    existing_fav_count    = existing_fav_artists.size
    new_artists.each do |a|
      fav_item = self.favorite_items.build
      fav_item.favoreditem = a
      fav_item.save
    end
  end

  def add_favorite_genres genres
    fav_genres_limit     = 3
    existing_fav_genres  = self.favorite_items.for_genres.map(&:favoreditem)
    new_genres           = genres - existing_fav_genres
    existing_fav_count   = existing_fav_genres.size
    new_genres.each do |g|
      fav_item = self.favorite_items.build
      fav_item.favoreditem = g
      fav_item.save
    end
  end

  def related_items limit = 2
    items  = []
    if self.is_fan?
      items = self.all_following(:limit =>limit,:order =>"rand()")
    elsif self.is_artist?
      items = Genre.get_artists_for_genres(self.genres)
    elsif self.is_venue?
      items = self.nearbys
    end
    items
  end

  def sidebar_suggestion_items limit = 5
    items  = []
    if self.is_fan?
      items = self.all_following(:limit =>limit,:order =>"rand()")
    elsif self.is_artist?
      items = Genre.get_artists_for_genres(self.genres)
    elsif self.is_venue?
      items = self.nearbys(30)    # other venues within 30 miles
    end
    items
  end

  def inbox page=1
    self.received_messages.paginate(:page => page, :per_page => MESSAGES_PER_PAGE)
  end

  def find_own_as_well_as_following_user_posts page=1
    # following fan ids
    f_u_ids    = self.following_users.map{|follow|  follow.id}
    f_u_ids    << self.id
    # following artist ids
    f_a_ids    = self.following_artists.map{|artist| artist.id}
    # following venue ids
    f_v_ids    = self.following_artists.map{|artist| artist.id}

    post_ids                            = []
    #    posts           = Post.joins('LEFT OUTER JOIN mentioned_posts ON posts.id = mentioned_posts.post_id').where('mentioned_posts.user_id = :current_user_id or (posts.user_id in (:current_user_as_well_as_following_users_id) or posts.artist_id in (:user_following_artist_ids))  and posts.is_deleted = :is_deleted and is_bulletin = false', :current_user_id => self.id, :current_user_as_well_as_following_users_id =>  user_as_well_as_following_users_id, :user_following_artist_ids => user_following_artist_ids, :is_deleted => false).order('posts.created_at DESC').uniq.paginate(:page => page, :per_page => POST_PER_PAGE).each{|post| post_ids << post.id}    
    posts      = Post.joins('LEFT OUTER JOIN mentioned_posts ON posts.id = mentioned_posts.post_id')
                  .where('((mentioned_posts.mentionitem_type = ? and mentioned_posts.mentionitem_id = ?) or (posts.useritem_type = ? and posts.useritem_id in (?)) or (posts.useritem_type = ? and posts.useritem_id in (?)) or (posts.useritem_type = ? and posts.useritem_id in (?))) and is_deleted is false', self.class.name, self.id, 'User', f_u_ids, 'Artist', f_a_ids, 'Venue', f_v_ids)
                  .order('posts.created_at DESC')
                  .uniq.paginate(:page => page, :per_page => POST_PER_PAGE)
                  .each{|post| post_ids << post.id}
    return posts  
  end

  def find_own_posts page = 1
    Post.where('useritem_type = ? and useritem_id = ? and is_deleted = ? and is_bulletin = ?', self.class.name,  self.id, false, false)
        .order('created_at DESC')
        .uniq.paginate(:page => page, :per_page => POST_PER_PAGE)
  end

  def find_own_as_well_as_mentioned_posts page=1
#    Post.joins('LEFT OUTER JOIN mentioned_posts ON posts.id = mentioned_posts.post_id')
#        .where('(mentioned_posts.mentionitem_id = ? and mentioned_posts.mentionitem_type = ? ) or (posts.useritem_id = ? and posts.useritem_type = ? and posts.is_deleted is false)', self.id, self.class.name, self.id, self.class.name)
#        .order('posts.created_at DESC')
#        .uniq.paginate(:page => page, :per_page => POST_PER_PAGE)    
    post_ids = []
    posts = Post.joins('LEFT OUTER JOIN mentioned_posts ON posts.id = mentioned_posts.post_id')
                .where('mentioned_posts.mentionitem_id = ? and mentioned_posts.mentionitem_type = ? or (posts.useritem_id = ? and posts.useritem_type = ?) and posts.is_deleted is false and posts.is_bulletin is false', self.id, self.class.name, self.id, self.class.name)
                .order('posts.created_at DESC').uniq
                .paginate(:page => page, :per_page => POST_PER_PAGE)
                .each{|post| post_ids << post.id}
    mark_mentioned_post_as_read post_ids    
    return posts
  end

  # not for fan type
  def bulletins page = 1
    Post.where('useritem_type = ? and useritem_id = ? and is_bulletin = ? and is_deleted = ?', self.class.name, self.id, true, false)
        .order('created_at desc')
        .paginate(:page => page, :per_page => POST_PER_PAGE)
  end

  def item_mentioned_posts page = 1
    post_ids          = []
    posts             = Post.joins(:mentioned_posts)
                            .where('mentioned_posts.mentionitem_id = ? and mentioned_posts.mentionitem_type = ? and is_deleted is false',  self.id, self.class.name)
                            .order('posts.created_at DESC').uniq
                            .paginate(:page => page, :per_page => POST_PER_PAGE)
                            .each{|post| post_ids << post.id}
    mark_mentioned_post_as_read post_ids
    return posts
  end

  def unread_mentioned_post_count
    self.mentioned_posts.where(:status => UNREAD).count
  end

  def unread_post_replies_count
    unread_post_replies.count
  end

  def replies_post page=1
    item_post_ids   = self.posts.where('is_newsfeed is false and is_deleted is false').map{|post| post.id}
    posts           = Post.where('reply_to_id in (?) and is_deleted is false', item_post_ids).order('created_at desc')
                          .paginate(:page => page, :per_page => POST_PER_PAGE)
    post_ids        = posts.map{|post| post.id}
    mark_replies_post_as_read post_ids
    return posts
  end

  protected

  def mark_mentioned_post_as_read post_ids
    self.mentioned_posts.where(:post_id => post_ids).update_all(:status => READ)
  end

  def mark_replies_post_as_read post_ids
    unread_replies_post_ids = unread_post_replies.map{|post| post.id}
    post_need_to_be_marked_as_read = post_ids & unread_replies_post_ids
    Post.where(:id => post_need_to_be_marked_as_read).update_all(:is_read => READ)
  end

  def unread_post_replies
    user_post_ids = self.posts.where('is_newsfeed is false and is_deleted is false').map{|post| post.id}
    Post.where('reply_to_id in (?) and is_read = ? and is_deleted is false', user_post_ids, UNREAD)
  end  
  
end