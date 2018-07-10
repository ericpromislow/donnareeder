require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should edit a user" do
    user = users(:wally)
    get edit_user_path(user)
    assert_response :success
  end

end
