module ApplicationHelper

  def timeago(time, options = {})
    #options[:class] ||= "timeago"
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
  
  def get_fan_profile_image(user, my_avatar = false)
    actor     = current_actor
    my_avatar = actor == user
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

  def get_artist_avatar(band)
    unless band.band_logo(true)    
      image_tag('profile/artist-defaults-photo-thumbnail.jpg', :alt=>'')
    else
      image_tag(band.band_logo.logo.url(:small), :alt=>'')
    end  
  end
  
  def get_artist_avatar_large(band)
    unless band.band_logo(true)    
      image_tag('artist-defaults-photo-profile.jpg', :alt=>'')
    else
      image_tag(band.band_logo.logo.url(:medium), :alt=>'')
    end
  end
  
  def get_artist_profile_image(band, self_logo = false)
    actor     = current_actor
    self_logo = actor == band
    random_profile_images = ["profile/artist-defaults-photo-profile-a.jpg", "profile/artist-defaults-photo-profile-b.jpg", "profile/artist-defaults-photo-profile-c.jpg", "profile/artist-defaults-photo-profile-d.jpg"]
    if self_logo
      raw (render :partial => '/bricks/artist_profile_image', :locals => {:band => band})
    else
      if band.band_logo
        image_tag(band.band_logo.logo.url(:large), :alt=>'')
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
      (width.nil? and height.nil?) ? image_tag(song_album.cover_img.url(type), :alt=>'') : image_tag(song_album.cover_img.url(type), :width =>width,:height=>height, :alt=>'')
    end
  end

  def get_album_cover(song_album, type=:small, width=nil, height=nil)
    if song_album.cover_img_content_type.nil?
      '/assets/no-image.png'
    else
      song_album.cover_img.url(type)
    end
  end
  
  def get_band_photo_album_teaser_photo(band_photo_album, type=:thumb, width=nil, height=nil)
    cover_image = band_photo_album.cover_image
    if cover_image.blank?
      image_tag('no-image.png', :alt=>'')
    else
      (width.nil? and height.nil?) ? image_tag(cover_image.image.url(type), :alt=>'') : image_tag(cover_image.image.url(type), :alt=>'', :height =>height, :width=>width)
    end
  end

  def can_admin?(band, user)
    user.is_admin_of_band?(band)
  end

  def post_msg_with_band_mention(post)    
    weblink_reg_http  = /(\b(?:https?:\/\/|www\.)\S+\b.\S{2,})/
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
    post_msg.gsub!(weblink_reg_http){|m| "#{link_to($1, 'http://' + $1.gsub('http://',''), :target=>'_blank')}"}
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
        content       += " added a new photo album <a href='#{album_path}' class='ajaxopen backable' data-remote='true'> #{album_name} </a>"
      elsif post.band_photo_post?
        album         = postitem.band_album
        album_name    = album.name
        album_path    = "#{band_album_path(band.name, album_name)}"
        content       += " added a new photo to the <a href='#{album_path}' class='ajaxopen backable' data-remote='true'> #{album_name} </a> album"
        message       =  raw (render '/band_photos/band_photo', :photo =>postitem, :band_album =>album, :band =>band, :in_newsfeed =>true)
      elsif post.band_tour_post?
        show_id       = postitem.id
        show_venue    = postitem.venue
        show_country  = postitem.country
        show_path     = band_tour_path(band.name,show_id)
        content       += " has created a new <a href='#{show_path}' class='ajaxopen backable' data-remote=true>show</a> at #{show_venue}"
      elsif post.song_post?
        album_name    = postitem.song_album.album_name
        album_path    = "#{band_song_album_path(band.name, album_name)}"
        content       += " added a new song to the <a href='#{album_path}' class='ajaxopen backable' data-remote='true'> #{album_name} </a> album"
        message       = raw(render '/band_song_album/song_item', :song =>postitem, :band =>band, :in_newsfeed =>true)
      elsif post.song_album_post?
        album_name    = postitem.album_name
        album_path    = "#{band_song_album_path(band.name, album_name)}"
        content       += " added a new music album <a href='#{album_path}' class='ajaxopen backable' data-remote='true'> #{album_name} </a>"
      end
    end
    [content.html_safe, message.html_safe]
  end

  # returns the message for buzz items for song, song album, artist photo, artist photo album, artist show
  # linked with corresponding buzzed items
  def post_message post, postitem
    content         = " wrote about "
    message         = ""
    if post && postitem      
      if post.band_album_post?
        band          = postitem.band
        album_name    = postitem.name
        album_path    = "#{band_album_path(band.name, album_name)}"
        content       += "artist photo album <a href='#{album_path}' class='ajaxopen backable' data-remote='true'> #{album_name} </a>"
      elsif post.band_photo_post?
        band          = postitem.band_album.band
        album         = postitem.band_album
        album_name    = album.name
        album_path    = "#{band_album_path(band.name, album_name)}"
        content       += "artist photo <a href='#{album_path}' class='ajaxopen backable' data-remote='true'> #{album_name} </a>"
      elsif post.band_tour_post?
        band          = postitem.band
        show_id       = postitem.id
        show_venue    = postitem.venue
        show_country  = postitem.country
        show_path     = band_tour_path(band.name,show_id)
        content       += "artist show <a href='#{show_path}' class='ajaxopen backable' remote=true>show</a>(at #{show_venue}, #{show_country})"
      elsif post.song_post?
        band          = postitem.song_album.band
        album_name    = postitem.song_album.album_name
        album_path    = "#{band_song_album_path(band.name, album_name)}?h=#{postitem.id}"
        content       += " song <a href='#{album_path}' class='ajaxopen backable' data-remote='true'> #{postitem.title} </a>"
      elsif post.song_album_post?
        band          = postitem.band
        album_name    = postitem.album_name
        album_path    = "#{band_song_album_path(band.name, album_name)}"
        content       += "<a href='#{album_path}' class='ajaxopen backable' data-remote='true'> #{album_name} </a>"
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
      link = show_band_url(actor.name)
    end
    return {:name =>name, :link =>link}
  end

  def buzz_item_detail item
    case item.class.name
    when 'SongAlbum'
      type    = 'Song Album'
      name    = item.album_name
      artist  = item.band
    when 'Song'
      type    = 'Song'
      name    = item.title
      artist  = item.song_album.band
    when 'BandAlbum'
      type    = 'Photo Album'
      name    = item.name
      artist  = item.band
    when 'BandPhoto'
      type    = 'Photo'
      name    = nil
      artist  = item.band
    when 'BandTour'
      type    = 'Show'
      name    = nil
      artist  = item.band
    end
    return {:type =>type, :name =>name, :artist =>artist}
  end
  
end
