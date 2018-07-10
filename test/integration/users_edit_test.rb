require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:wally)
  end

  test 'unsuccessful edit' do
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
end
