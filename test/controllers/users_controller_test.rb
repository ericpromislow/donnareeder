require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:wally)
    @archer = users(:archer)
    @lana = users(:lana)
    @node_languages = nodes(:languages)
    @node_python = nodes(:python)
    @node_javascript = nodes(:javascript)
    @node_guido = nodes(:guido)
    @node_brendon = nodes(:brendon)
    @feed_guido = feeds(:guido)
    @feed_brendon = feeds(:brendon)
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

  test 'should not allow the admin attr to be updated via the web interface' do
    log_in_as(@archer)
    assert_not(@archer.admin?)
    patch user_path(@archer), params: { user: { admin: true }}
    assert_not @archer.reload.admin?
    assert_redirected_to user_url(@archer)
  end

  test 'destroy fails when not logged in' do
    assert_no_difference 'User.count' do
      delete user_path(@lana)
    end
    assert_not_nil User.find(@lana.id)
    assert_redirected_to login_url
  end

  test 'non-admin should not delete the user' do
    log_in_as(@archer)
    assert_no_difference 'User.count' do
      delete user_path(@lana)
    end
    assert_redirected_to root_url
    assert_not_nil User.find_by_id(@lana.id)
  end

  test 'an admin should delete the user' do
    log_in_as(@user)
    assert_difference 'User.count', -1 do
      delete user_path(@lana)
    end
    assert_nil User.find_by_id(@lana.id)
  end

  test 'a non-admin can delete himself' do
    log_in_as(@lana)
    assert_difference 'User.count', -1 do
      delete user_path(@lana)
    end
    assert_nil User.find_by_id(@lana.id)
    assert_redirected_to root_url
    assert_not is_logged_in?
  end

  test 'a user can see his feed tree' do
    log_in_as(@user)
    @node_brendon.update!(parent: @node_javascript)
    @node_guido.update!(parent: @node_python)
    @node_python.update!(parent: @node_languages)
    @node_javascript.update!(parent: @node_languages)
    @feed_guido.update!(node: @node_guido)
    @feed_brendon.update!(node: @node_brendon)
    get user_path(@user)
    assert_equal response.status, 200
    assert_template 'users/show'
    debugger
    assert_select 'ul[class="ul-nodelist"] li[class="node"] ul[class="ul-nodelist"] li[class="feed"]', text:'be brave, js'
  end    
end
