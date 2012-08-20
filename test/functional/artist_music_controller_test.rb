require 'test_helper'

class ArtistMusicControllerTest < ActionController::TestCase

  test "should get the artist musics list" do
    artist = artists(:artists_001)
    get :index, {:artist_name =>artist.mention_name}, {:user_id =>1}
    artist_musics = assigns(:artist_music_list)
    assert_not_nil artist_musics
    assert_template 'artist_music/index'
  end
end
