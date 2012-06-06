require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get code" do
    get :code
    assert_response :success
  end

  test "should get token" do
    get :token
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
