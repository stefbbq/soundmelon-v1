module ApplicationHelper
  
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association)
    new_object  = f.object.class.reflect_on_association(association).klass.new
    fields      = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, ("add_fields(this, '#{association}', '#{escape_javascript(fields)}')"))
  end
  
  def get_avatar_small(user)
    if user.profile_pic
      image_tag(user.profile_pic.avatar.url(:small), :alt=>'')
    else
      image_tag('fan-defaults-photo-thumbnail.jpg', :alt=>'')
    end
  end
  
  def get_avatar_medium(user)
    if user.profile_pic
      image_tag(user.profile_pic.avatar.url(:medium), :alt=>'')
    else
      image_tag('fan-defaults-photo-profile.jpg', :alt=>'')
    end
  end
  
  def get_avatar_large(user, my_avatar = false)
    actor     = current_actor
    my_avatar = actor == user
    if my_avatar       
      raw (render :partial => '/bricks/avatar_profile', :locals => {:user => user})
    else
      if user.profile_pic
        image_tag(user.profile_pic.avatar.url(:large), :alt=>'')
      else
        image_tag('fan-defaults-photo-profile.jpg', :alt=>'')
      end
    end
  end

  def get_band_logo_small(band)
    unless band.band_logo(true)    
      image_tag('artist-defaults-photo-thumbnail.jpg', :alt=>'')
    else
      image_tag(band.band_logo.logo.url(:small), :alt=>'')
    end  
  end
  
  def get_band_logo_medium(band)
    unless band.band_logo(true)    
      image_tag('artist-defaults-photo-profile.jpg', :alt=>'')
    else
      image_tag(band.band_logo.logo.url(:medium), :alt=>'')
    end  
  end
  
  def get_band_logo_large(band, self_logo = false)
    actor     = current_actor
    self_logo = actor == band
    if self_logo
      raw (render :partial => '/bricks/artist_logo_profile', :locals => {:band => band})
    else
      if band.band_logo
        image_tag(band.band_logo.logo.url(:large), :alt=>'')
      else        
        image_tag('artist-defaults-photo-thumbnail.jpg', :alt=>'')
      end
    end    
  end
  
  def genre_atuofill
    genres         = Genre.all
    avail_genre    = ''
    genres.each do |genre|
      avail_genre += "{id: '#{genre.name}', name: '#{genre.name}'},"
    end
    return avail_genre
  end

  def genre_atuofill_band
    genres         = Genre.all
    avail_genre    = ''
    genres.each do |genre|
      avail_genre += "{id: '#{genre.id}', name: '#{genre.name}'},"
    end
    return avail_genre
  end
  
  def genre_prepopullate genres
    pre_popullate_genre = ''
    for genre in genres      
      pre_popullate_genre += "{id: '#{genre.id}', name: '#{genre.name}'},"
    end  
    return pre_popullate_genre
  end

  def genre_prepopullate_from_addinfo add_info
    pre_popullate_genre = ''
    unless add_info.nil?
      unless add_info.favourite_genre.blank?
        add_info.favourite_genre.split(',').each do |cur_genre|
          pre_popullate_genre += "{id: '#{cur_genre}', name: '#{cur_genre}'},"
        end
      end
    end
    return pre_popullate_genre
  end
  
  def user_mention_lists(user)
    auto_mention_list     = ''
    mention_list_arr      = []
    user.following_user.select('mention_name').map{|user_following| mention_list_arr << user_following.mention_name}
    user.user_followers.select('mention_name').map{|follower_user| mention_list_arr << follower_user.mention_name}
    user.following_band.select('mention_name').map{|band_following| mention_list_arr << band_following.mention_name}
    mention_list_arr.uniq.each do |mentioner|
      auto_mention_list += "{name: '#{mentioner}'},"
    end
    return auto_mention_list
  end
  
  def band_follower_mention_lists band
    auto_mention_list       = ''
    mention_list_arr        = []
    band.user_followers.select('mention_name').map{|follower_user| mention_list_arr << follower_user.mention_name}
    mention_list_arr.uniq.each do |mentioner|
      auto_mention_list     += "{name: '#{mentioner}'},"
    end
    return auto_mention_list
  end
  
  def get_album_cover_image(song_album, type=:small, width=nil, height=nil)
    if song_album.cover_img_content_type.nil?
      image_tag('no-image.png', :alt=>'')
    else
      (width.nil? and height.nil?) ? image_tag(song_album.cover_img.url(type), :alt=>'aa') : image_tag(song_album.cover_img.url(type), :width =>width,:height=>height, :alt=>'')
    end
  end

  def get_album_cover(song_album, type=:small, width=nil, height=nil)
    if song_album.cover_img_content_type.nil?
      'no-image.png'
    else
      song_album.cover_img.url(type)
    end
  end
  
  def get_band_photo_album_teaser_photo(band_photo_album, type=:thumb)
    cover_image = band_photo_album.cover_image
    if cover_image.blank?
      image_tag('no-image.png', :alt=>'')
    else
      image_tag(cover_image.image.url(type), :alt=>'', :height =>'35px;', :width=>'35px;')
    end
  end

  def can_admin?(band, user)
    user.is_admin_of_band?(band)
  end

  def post_msg_with_band_mention(post)
    post_msg          = post.msg    
    mentioned_users   = post.mentioned_users
    mentioned_bands   = post.mentioned_bands
    unless mentioned_users.blank?
      user_mentions   = mentioned_users.split(',')
      for i in 0..user_mentions.size-2
        um_id   = user_mentions[i]
        um_name = user_mentions[i+1]
        fan_profile_link_html = "<a href='#{fan_profile_path(um_id)}' class='ajaxopen backable' data-remote='true'>#{um_name}</a>"
        post_msg = post_msg.gsub(um_name, fan_profile_link_html)
        i = i+1
      end
    end
    unless mentioned_bands.blank?
      band_mentions = post.mentioned_bands.split(',')

      band_mentions.each{|mb|
        band_profile_link_html = "<a href='#{show_band_path(mb.gsub('@',''))}' class='ajaxopen backable' data-remote='true'>#{mb}</a>"
        post_msg = post_msg.gsub(mb, band_profile_link_html)
      }
    end
    post_msg.html_safe
  end

  def newsfeed_message post, postitem    
    content         = ""
    message         = ""
    if post && postitem
      band            = post.band
      if post.band_album_post?
        album_name    = postitem.name
        album_path    = "#{band_album_path(band.name, album_name)}"
        content       += " added a new photo album <a href='#{album_path}' class='ajaxopen' remote='true'> #{album_name} </a>"
      elsif post.band_photo_post?
        album         = postitem.band_album
        album_name    = album.name
        album_path    = "#{band_album_path(band.name, album_name)}"
        content       += " added a new photo to the album <a href='#{album_path}' class='ajaxopen' remote='true'> #{album_name} </a>"
        message       =  raw (render '/band_photos/band_photo', :photo =>postitem, :band_album =>album, :band =>band, :in_newsfeed =>true)
      elsif post.band_tour_post?
        show_id       = postitem.id
        show_venue    = postitem.venue
        show_country  = postitem.country
        show_path     = band_tour_path(band.name,show_id)
        content       += " going to attend the <a href='#{show_path}' class='ajaxopen' remote=true>show</a> at #{show_venue}, #{show_country}"
      elsif post.song_post?
        album_name    = postitem.song_album.album_name
        album_path    = "#{band_song_album_path(band.name, album_name)}"
        content       += " added a new song to the album <a href='#{album_path}' class='ajaxopen' remote='true'> #{album_name} </a>"
        message       = raw(render '/band_song_album/song_item', :song =>postitem, :band =>band, :in_newsfeed =>true)
      elsif post.song_album_post?
        album_name    = postitem.album_name
        album_path    = "#{band_song_album_path(band.name, album_name)}"
        content       += " added a new song album <a href='#{album_path}' class='ajaxopen' remote='true'> #{album_name} </a>"
      end
    end
    [content.html_safe, message.html_safe]
  end

  # prepares the detail for individual song
  def song_detail song
    actor         = current_user
    song_detail   = song.song_detail
    id            = song_detail[:id]
    mp3           = song_detail[:mp3_song]
    ogg           = song_detail[:ogg_song]
    title         = song_detail[:song_title]
    album_name    = song_detail[:song_album_name]
    band_name     = song_detail[:song_album_band_name]
    song_album    = song_detail[:song_album]    
    album_image   = song_album ? get_album_cover(song_album).gsub("'", "\\\\'") : ''
    like          = song.voted_on_by?(actor) ? 1 : 0
    hash_str      = "{title: '#{title}', i:'#{id}'"
    hash_str      += ",album:'#{album_name}', band: '#{band_name}', mp3:'#{mp3}', ogg: '#{ogg}'"
    hash_str      += ",image: '#{album_image}',like:#{like}}"
    hash_str
  end

  # prepares the detail for list of songs
  def list_of_play_items songs
    list_str  = ""
    for i in 0..songs.size-1
      hash_str      = song_detail(songs[i])
      list_str      += hash_str
      list_str      +="," if i <= songs.size
    end
    list_str
  end  

end
