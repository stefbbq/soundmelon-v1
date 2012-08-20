require 'test_helper'

class UserPostsControllerTest < ActionController::TestCase

  # create post for fan
  test "should create post for a fan" do
    post_msg = 'test message'
    assert_difference('Post.count') do
      xhr :post, :create, {:post =>{:msg =>post_msg}}, {:user_id =>1}
    end
    new_post       = assigns(:new_post)
    actor          = assigns(:actor)
    assert_not_nil new_post
    assert_not_nil actor
    assert actor.instance_of?(User), "actor is not a fan"
    assert_equal actor.id, new_post.user_id
    assert_nil new_post.artist_id
    assert_equal post_msg, new_post.msg
    assert_template 'user_posts/create'
  end

  # create normal post for artist
  test "should create post for a artist" do
    post_msg = 'test message'
    artist   = artists(:artists_001)
    assert_difference('Post.count') do
      xhr :post, :create, {:post =>{:msg =>post_msg}}, {:user_id =>1, :artist_id =>artist.id}
    end
    new_post       = assigns(:new_post)
    actor          = assigns(:actor)
    assert_not_nil new_post
    assert_not_nil actor
    assert actor.instance_of?(Artist), "actor is not an artist"
    assert_equal actor.id, new_post.artist_id
    assert_nil new_post.user_id
    assert_equal post_msg, new_post.msg
    assert_template 'user_posts/create'
  end

  # create a pinned post for artist
  test "should create pinned post for a artist" do
    post_msg = 'test message'
    artist   = artists(:artists_001)
    assert_difference('Post.count') do
      xhr :post, :create, {:post =>{:msg =>post_msg, :is_bulletin =>1}}, {:user_id =>1, :artist_id =>artist.id}
    end
    new_post       = assigns(:new_post)
    actor          = assigns(:actor)
    assert_not_nil new_post
    assert_not_nil actor
    assert actor.instance_of?(Artist), "actor is not an artist"
    assert_equal actor.id, new_post.artist_id
    assert_nil new_post.user_id
    assert_equal post_msg, new_post.msg
    assert new_post.is_bulletin?
    assert_template 'user_posts/create'
  end

  # replying to some post
  test "should new reply create new post as a reply post" do
    p_post   = posts(:posts_001)
    post_msg = 'test message'
    assert_difference('Post.count') do
      xhr :post, :reply, {:post =>{:msg =>post_msg}, :parent_post_id =>p_post.id}, {:user_id =>1}
    end
    parent_post    = assigns(:parent_post)
    new_post       = assigns(:post)
    actor          = assigns(:actor)
    status         = assigns(:saved_successfully)
    assert_not_nil parent_post
    assert_not_nil new_post
    assert_not_nil actor    
    assert_equal actor.id, new_post.user_id
    assert_equal parent_post.id, new_post.reply_to_id    
    assert_equal post_msg, new_post.msg
    assert_not_nil status
    assert_equal true, status
    assert_template 'user_posts/reply'
  end

  # rendering the popup for artist mention
  test "sould new mention for artist render the popup" do
    artist      = artists(:artists_001)
    xhr :get, :new_mention_post, {:artist_id =>artist.id}, {:user_id =>1, :artist_id =>2}
    post_object = assigns(:post)
    assert_not_nil post_object, "no post object has been initialized"
    assert_equal "@#{artist.mention_name}", post_object.msg
    assert_nil post_object.id
    assert_template 'user_posts/new_mention_post'
  end

  # creating post with artist mention
  test "should new mention post for artist create new mention post" do
    artist      = artists(:artists_001)
    assert_difference(['Post.count', 'MentionedPost.count']) do
      xhr :post, :create_mention_post, {:artist_id =>artist.id, :post =>{:msg =>"@#{artist.mention_name} what's up"}}, {:user_id =>1, :artist_id =>2}
    end    
    post        = assigns(:post)
    status      = assigns(:saved_successfully)
    assert_not_nil post
    assert_not_nil status
    assert status
    assert_not_nil post, "no post object has been initialized"
    assert_not_nil post.id
    assert post.mentioned_artists.include?(artist.mention_name)
    assert_template 'user_posts/create_mention_post'
  end

end
