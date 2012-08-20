require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  test "should get index" do
    user     = users(:users_001)
    get :index, {:q =>'search term'}, {:user_id =>user.id}
    assert_response :success
    fan_results     = assigns(:fan_search_results)
    artist_results  = assigns(:artist_search_results)
    assert_not_nil fan_results
    assert_not_nil artist_results
    assert_template 'search/index'
  end

  # ajax call
  test "should get index on ajax call" do
    user     = users(:users_001)
    xhr :get, :index, {:q =>'search term'}, {:user_id =>user.id}
    assert_response :success
    fan_results     = assigns(:fan_search_results)
    artist_results  = assigns(:artist_search_results)
    assert_not_nil fan_results
    assert_not_nil artist_results
    assert_template 'search/index'
  end

  

end
