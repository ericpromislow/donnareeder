require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:wally)
    @archer = users(:archer)
  end
  
  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should edit a user" do
    user = users(:wally)
    log_in_as user
    get edit_user_path(user)
    assert_response :success
  end

  test 'edit should redirect when not logged in' do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'update should redirect when not logged in' do
    patch user_path(@user), params: {user: {name: @user.name, email: 'myemail@yost.com',
                                            password: 'my own password',
                                            password_confirmation: 'my own password', }}
                                             
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect when logged in as wrong user' do
    log_in_as(@archer)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect index when not logged in' do
    get users_path
    assert_redirected_to login_url
  end

  test 'should redirect index when not an admin' do
    log_in_as(@archer)
    get users_path
    assert_redirected_to root_url
  end

  test 'should get the users when a admin' do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
  end

end
