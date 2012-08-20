require 'test_helper'

class ArtistTest < ActiveSupport::TestCase

  test "sould not save the artist without name" do
    artist = Artist.new
    assert !artist.valid?, "Artist should have name"
  end

  test "should not allow the artist with duplicate name" do
    artist1 = Artist.find :first
    artist2 = Artist.find :last
    artist2.name = artist1.name
    assert !artist2.valid?, "Duplicate name for artist"
  end

  test "should not save the artist without mention name" do
    artist = Artist.new
    assert !artist.valid?, "Artist should have mention name"
  end

  test "should not allow the artist with duplicate mention name" do
    artist1 = Artist.find :first
    artist2 = Artist.find :last
    artist2.mention_name = artist1.mention_name
    assert !artist2.valid?, "Duplicate mention name for artist"
  end

  test "should ignore mention name of single character" do
    artist = Artist.find :first
    artist.mention_name = 'p'
    assert !artist.save
  end

  test "should remove artist and artist's items" do
    artist = artists(:artists_001)
    assert_difference('Artist.count', -1) do
      artist.remove_me
    end    
  end

end
