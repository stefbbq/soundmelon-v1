module ApplicationHelper

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    #content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
    "#{time_ago_in_words(time)} ago"
  end
  
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
  
  def get_fan_avatar(user)
    if user.profile_pic
      image_tag(user.profile_pic.avatar.url(:small), :alt=>'')
    else
      image_tag('profile/fan-defaults-photo-avatar.jpg', :alt=>'')
    end
  end
  
  def get_fan_avatar_large(user)
     if user.profile_pic
       image_tag(user.profile_pic.avatar.url(:medium), :alt=>'')
     else
       image_tag('profile/fan-defaults-photo-avatar-large.jpg', :alt=>'')
     end
   end
  
  def get_fan_profile_image(user, my_avatar = false)    
    if my_avatar
      raw (render :partial => '/bricks/fan_profile_image', :locals => {:user => user})
    else
      if user.profile_pic
        image_tag(user.profile_pic.avatar.url(:large), :alt=>'')
      else
        image_tag('profile/fan-defaults-photo-profile.jpg', :alt=>'')
      end
    end
  end

  def get_artist_avatar(artist)
    unless artist.artist_logo(true)    
      image_tag('profile/artist-defaults-avatar.jpg', :alt=>'')
    else
      image_tag(artist.artist_logo.logo.url(:small), :alt=>'')
    end  
  end
  
  def get_artist_avatar_large(artist)
    unless artist.artist_logo(true)    
      image_tag('profile/artist-defaults-avatar-large.jpg', :alt=>'')
    else
      image_tag(artist.artist_logo.logo.url(:medium), :alt=>'')
    end
  end
  
  def get_artist_profile_image(artist, self_logo = false)    
    random_profile_images = ["profile/artist-defaults-photo-profile-a.jpg", "profile/artist-defaults-photo-profile-b.jpg", "profile/artist-defaults-photo-profile-c.jpg", "profile/artist-defaults-photo-profile-d.jpg"]
    if self_logo
      raw (render :partial => '/bricks/artist_profile_image', :locals => {:artist => artist})
    else
      if artist.artist_logo
        image_tag(artist.artist_logo.logo.url(:large), :alt=>'')
      else
        image_tag(random_profile_images.sample, :alt=>'')
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

  def genre_atuofill_artist
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
  
  # get user mentions auto-complete entry
  def user_mention_lists(user)
    auto_mention_list     = ''
    mention_list_arr      = []
    mention_list_arr << user.following_users.to_a
    mention_list_arr << user.user_followers.to_a
    mention_list_arr << user.following_artists.to_a
    
    mention_list_arr.flatten.uniq.each do |mentionable_item|
      mention_name      = "@#{mentionable_item.mention_name}"
      display_name      = "#{mention_name} - #{mentionable_item.get_name}"
      object_type       = mentionable_item.class.to_s.downcase
      # reset object type to fan or artist (needs to be fixed in database)
      object_type       = (object_type == "artist") ? "artist" : "fan"
      auto_mention_list += "{name: \"#{display_name}\", id:\"#{mention_name}\", type:\"#{object_type}\"},"
    end
    return auto_mention_list.chomp(",")
  end
  
  def artist_follower_mention_lists artist
    auto_mention_list   = ''
    mention_list_arr    = artist.user_followers.to_a    
    mention_list_arr.flatten.uniq.each do |mentionable_item|
      mention_name      = "@#{mentionable_item.mention_name}"
      display_name      = "#{mentionable_item.get_name}(#{mention_name})"
      object_type       = mentionable_item.class.to_s.downcase
      auto_mention_list += "{name: \"#{display_name}\", id:\"#{mention_name}\", type:\"#{object_type}\"},"
    end
    return auto_mention_list
  end
  
  def get_album_cover_image(song_album, type=:small, width=nil, height=nil)
    if song_album.cover_img_content_type.nil?
      image_tag('profile/artist-defaults-avatar.jpg', :alt=>'')
    else
      (width.nil? and height.nil?) ? image_tag(song_album.cover_img.url(type), :alt=>'') : image_tag(song_album.cover_img.url(type), :width =>width,:height=>height, :alt=>'')
    end
  end

  def get_album_cover(song_album, type=:small, width=nil, height=nil)
    if song_album.cover_img_content_type.nil?
      '/assets/profile/artist-defaults-avatar.jpg'
    else
      song_album.cover_img.url(type)
    end
  end
  
  def get_artist_photo_album_teaser_photo(artist_photo_album, type=:thumb, width=nil, height=nil)
    cover_image = artist_photo_album.cover_image
    if cover_image.blank?
      image_tag('profile/artist-defaults-avatar.jpg', :alt=>'', :height =>'35px', :width=>'35px')
    else
      (width.nil? and height.nil?) ? image_tag(cover_image.image.url(type), :alt=>'') : image_tag(cover_image.image.url(type), :alt=>'', :height =>height, :width=>width)
    end
  end

  def can_admin?(artist, user)
    user.is_admin_of_artist?(artist)
  end

  def post_msg_with_artist_mention post, link_class = nil
    link_class          = 'ajaxopen backable' unless link_class
    post_msg            = post.msg
    mentioned_users     = post.mentioned_users
    mentioned_artists   = post.mentioned_artists
    unless mentioned_users.blank?
      user_mentions     = mentioned_users.split(',')
      for i in 0..user_mentions.size-2
        um_id           = user_mentions[i]
        um_name         = user_mentions[i+1]
        fan_profile_link_html = "<a href='#{fan_profile_path(um_id)}' class='#{link_class}' data-remote='true'>@#{um_name}</a>"
        post_msg = post_msg.gsub("@#{um_name}", fan_profile_link_html)
        i = i+1
      end
    end
    unless mentioned_artists.blank?
      artist_mentions   = post.mentioned_artists.split(',')
      artist_mentions.each{|mb|
        artist_profile_link_html = "<a href='#{show_artist_path(mb)}' class='#{link_class}' data-remote='true'>@#{mb}</a>"
        post_msg = post_msg.gsub("@#{mb}", artist_profile_link_html)
      }
    end
    post_msg = Rinku.auto_link(post_msg, :all, 'target="_blank"')
    post_msg.html_safe
  end

  def newsfeed_message post, postitem, link_class = nil
    content         = ""
    message         = ""
    link_class      = 'ajaxopen backable' unless link_class
    if post && postitem
      if post.artist_album_post?
        artist        = post.artist
        album_name    = postitem.name
        album_path    = "#{artist_album_path(artist, album_name)}"
        content       += " added a new photo album <a href='#{album_path}' class='#{link_class}' data-remote='true'> #{album_name} </a>"
      elsif post.artist_photo_post?
        artist        = post.artist
        album         = postitem.artist_album
        album_name    = album.name
        album_path    = "#{artist_album_path(artist, album_name)}"
        content       += " added a new photo to the <a href='#{album_path}' class='#{link_class}' data-remote='true'> #{album_name} </a> album"
        message       =  raw (render '/artist_photo/photo', :photo =>postitem, :artist_album =>album, :artist =>artist, :in_newsfeed =>true)
      elsif post.artist_show_post?
        artist        = postitem.artist
        show_id       = postitem.id
        show_venue    = postitem.venue
        show_city     = postitem.city
        show_path     = artist_show_path(artist, show_id)
        content       += " has created a new <a href='#{show_path}' class='#{link_class}' data-remote=true>show</a> at #{show_venue} of #{show_city}"
      elsif post.song_post?
        artist        = post.artist
        album_name    = postitem.artist_music.album_name
        album_path    = "#{artist_music_path(artist, album_name)}"
        content       += " added a new song to the <a href='#{album_path}' class='#{link_class}' data-remote='true'> #{album_name} </a> album"
        message       = raw(render '/artist_music/song_item', :song =>postitem, :artist =>artist, :in_newsfeed =>true)
      elsif post.artist_music_post?
        artist        = post.artist
        album_name    = postitem.album_name
        album_path    = "#{artist_music_path(artist, album_name)}"
        content       += " added a new music album <a href='#{album_path}' class='#{link_class}' data-remote='true'> #{album_name} </a>"
      end
    end
    [content.html_safe, message.html_safe]
  end

  # returns the message for buzz items for song, song album, artist photo, artist photo album, artist show
  # linked with corresponding buzzed items
  def post_message post, postitem, link_class = nil
    link_class = 'ajaxopen backable' unless link_class
    content         = " wrote about "
    message         = ""
    if post && postitem
      if post.artist_album_post?
        artist        = postitem.artist
        album_name    = postitem.name
        album_path    = "#{artist_album_path(artist, album_name)}"
        content       += "artist photo album <a href='#{album_path}' class='#{link_class}' data-remote='true'> #{album_name} </a>"
      elsif post.artist_photo_post?
        artist        = postitem.artist_album.artist
        album         = postitem.artist_album
        album_name    = album.name
        album_path    = "#{artist_album_path(artist, album_name)}"
        content       += "artist photo <a href='#{album_path}' class='#{link_class}' data-remote='true'> #{album_name} </a>"
      elsif post.artist_show_post?
        artist        = postitem.artist
        show_id       = postitem.id
        show_venue    = postitem.venue
        show_city     = postitem.city
        show_path     = artist_show_path(artist, show_id)
        content       += "artist show <a href='#{show_path}' class='#{link_class}' remote='true'>show</a>(at #{show_venue} of #{show_city})"
      elsif post.song_post?
        artist        = postitem.artist
        album_name    = postitem.artist_music.album_name
        album_path    = "#{artist_music_path(artist, album_name)}?h=#{postitem.id}"
        content       += " song <a href='#{album_path}' class='#{link_class}' data-remote='true'> #{postitem.title} </a>"
      elsif post.artist_music_post?
        artist        = postitem.artist
        album_name    = postitem.album_name
        album_path    = "#{artist_music_path(artist, album_name)}"
        content       += "<a href='#{album_path}' class='#{link_class}' data-remote='true'> #{album_name} </a>"
      end
    end
    [content.html_safe, message.html_safe]
  end

  # prepares the detail for individual song
  def song_detail song
    actor             = current_user
    song_detail       = song.song_detail
    id                = song_detail[:id]
    mp3               = song_detail[:mp3_song]
    ogg               = song_detail[:ogg_song]
    title             = song_detail[:song_title]
    album_name        = song_detail[:artist_music_name]
    artist_name       = song_detail[:artist_music_artist_name]
    artist_username   = song_detail[:artist_username]
    artist_music      = song_detail[:artist_music]
    album_image       = artist_music ? get_album_cover(artist_music).gsub("'", "\\\\'") : ''
    like              = actor ? (song.voted_on_by?(actor) ? 1 : 0) : 0
    hash_str          = "{title: '#{title}', i:'#{id}'"
    hash_str          += ",album:'#{album_name}', artist: '#{artist_name}', artist_username:'#{artist_username}', mp3:'#{mp3}', ogg: '#{ogg}'"
    hash_str          += ",image: '#{album_image}',like:#{like}}"
    hash_str
  end

  # prepares the detail for list of songs
  def list_of_play_items songs
    list_str  = ""
    unless songs.blank?
      for i in 0..songs.size-1
        hash_str      = song_detail(songs[i])
        list_str      += hash_str
        list_str      +="," if i <= songs.size
      end
    end
    list_str
  end

  # returns detail for actor
  def actor_detail actor
    if actor.is_fan?
      name = actor.get_full_name
      link = fan_profile_url(actor)
    else
      name = actor.name
      link = show_artist_url(actor)
    end
    return {:name =>name, :link =>link}
  end

  def buzz_item_detail item
    case item.class.name
    when 'ArtistMusic'
      type    = 'Artist Music'
      name    = item.album_name
      artist  = item.artist
    when 'Song'
      type    = 'Song'
      name    = item.title
      artist  = item.song_album.artist
    when 'ArtistAlbum'
      type    = 'Photo Album'
      name    = item.name
      artist  = item.artist
    when 'ArtistPhoto'
      type    = 'Photo'
      name    = nil
      artist  = item.artist
    when 'ArtistShow'
      type    = 'Show'
      name    = nil
      artist  = item.artist
    end
    return {:type =>type, :name =>name, :artist =>artist}
  end
  
end
