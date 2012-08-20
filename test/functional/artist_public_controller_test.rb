require 'test_helper'

class ArtistPublicControllerTest < ActionController::TestCase
  test "should get page for artist public page for logged-in user" do
    artist = artists(:artists_001)
    get :index, {:artist_name =>artist.mention_name}, {:user_id =>1}
    show_artist   = assigns(:artist)
    artist_member = assigns(:artist_members_count)
    is_public     = assigns(:is_public)
    link_access   = assigns(:has_link_access)
    assert_not_nil show_artist
    assert_equal artist.id, show_artist.id
    assert_not_nil artist_member
    assert_not_nil is_public
    assert_equal true, is_public
    assert_not_nil link_access
    assert_equal false, link_access
    assert_template 'artist_public/index'
  end

  test "should get page for artist public page for non-logged-in user" do
    artist = artists(:artists_001)
    get :index, {:artist_name =>artist.mention_name}
    show_artist   = assigns(:artist)
    artist_member = assigns(:artist_members_count)
    is_public     = assigns(:is_public)
    link_access   = assigns(:has_link_access)
    assert_not_nil show_artist
    assert_equal artist.id, show_artist.id
    assert_not_nil artist_member
    assert_not_nil is_public
    assert_equal true, is_public
    assert_not_nil link_access
    assert_equal false, link_access
    assert_template 'artist_public/publicprofile'
  end

  test "should get artist members" do
    artist = artists(:artists_001)
    get :members, {:artist_name =>artist.mention_name}, {:user_id =>1}
    members = assigns(:artist_members)
    show_artist   = assigns(:artist)
    assert_not_nil show_artist
    assert_equal artist.id, show_artist.id
    assert_not_nil members
    assert_template 'artist_public/members'
  end
  
  test "should get the message popup for ajax request" do
    artist = artists(:artists_001)
    xhr :get, :new_message, {:id =>artist.id}, {:user_id =>1}
    artist_m = assigns(:artist)
    message  = assigns(:message)
    assert_not_nil artist_m
    assert_equal artist.id, artist_m.id
    assert_not_nil message
    assert_template 'artist_public/new_message'
  end

  test "should redirect to root path for non-ajax request" do
    artist = artists(:artists_001)
    get :new_message, {:id =>artist.id}, {:user_id =>1}
    assert_redirected_to root_url    
  end

  test "should send a message to the artist" do
    artist = artists(:artists_001)
    assert_difference('Message.count') do
      xhr :post, :send_message, {:body =>'message content', :id =>artist.id}, {:user_id =>1}
    end
  end

end
