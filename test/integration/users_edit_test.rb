require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:wally)
    @archer = users(:archer)
  end

  test 'not logged int' do
    get edit_user_path(@user)
    assert_redirected_to login_path
  end
  
  test 'unsuccessful edit' do
    log_in_as @user
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: {name: '',
                                             email: 'zip',
                                             password: 'p1',
                                             password_confirmation: 'p2'}}
    assert_equal(["Name can't be blank",
                  "Email is invalid",
                  "Password is too short (minimum is 8 characters)",
                  "Password confirmation doesn't match Password"].sort,
                 assigns(:user).errors.full_messages.sort)
    assert_template 'users/edit'
  end

  test 'successful edit' do
    log_in_as @user
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = 'vassily'
    email = 'vassily@art.com'
    patch user_path(@user), params: { user: {name: name,
                                             email: email,
                                             password: '',
                                             password_confirmation: ''}}
    assert_not flash.empty?, flash.to_hash
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test 'successful edit with friendly forwarding' do
    get edit_user_path(@user)
    log_in_as @user
    assert_redirected_to edit_user_url(@user)
    follow_redirect!
    assert_template 'users/edit'
  end
  
  test "trying to set admin attr as non-admin" do
    log_in_as(@archer)
    patch user_path(@archer), params: { user: { admin: true }}
    assert_redirected_to user_url(@archer)
    follow_redirect!
    assert_template 'users/show'
  end
end
