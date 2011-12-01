module ApplicationHelper
  
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, ("add_fields(this, '#{association}', '#{escape_javascript(fields)}')"))
  end
  
  def get_avatar_small(user)
    if user.profile_pic
      image_tag(user.profile_pic.avatar.url(:small))
    else
      image_tag('user_blank_small.jpg')
    end
  end
  
  def get_avatar_large(user, my_avatar = false)
    if my_avatar
      if user.profile_pic(true)
        raw "<div>#{link_to 'Change', new_avatar_path, :remote=>:true,:class=>'ajaxopen'} #{link_to 'Delete', delete_avatar_path, :remote=>:true}</div><div>#{image_tag(user.profile_pic.avatar.url(:large))}</div>"  
      else
        raw "<div>#{link_to 'Add', new_avatar_path, :remote=>:true,:class=>'ajaxopen'}</div><div>#{image_tag('user_blank_large.jpg')}</div>"
      end
    else
      if user.profile_pic
        image_tag(user.profile_pic.avatar.url(:large))
      else
        image_tag('user_blank_large.jpg')
      end
    end
  end
  
end
