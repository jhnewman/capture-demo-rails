require 'test_helper'

class DemoControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get authCallback" do
    get :authCallback
    assert_response :success
  end

  test "should get view_profile" do
    get :view_profile
    assert_response :success
  end

end
