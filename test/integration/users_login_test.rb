require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  include SessionsHelper
  
  def setup
    @user = users(:wally)
  end

  def setup_feed_tree
    @node_languages = nodes(:languages)
    @node_python = nodes(:python)
    @node_javascript = nodes(:javascript)
    @node_guido = nodes(:guido)
    @node_brendon = nodes(:brendon)
    @feed_guido = feeds(:guido)
    @feed_brendon = feeds(:brendon)
    @node_brendon.update!(parent: @node_javascript)
    @node_guido.update!(parent: @node_python)
    @node_python.update!(parent: @node_languages)
    @node_javascript.update!(parent: @node_languages)
    @feed_guido.update!(node: @node_guido)
    @feed_brendon.update!(node: @node_brendon)
  end

  test 'login with invalid info shows flash only once' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" }}
    assert_template 'sessions/new'
    assert_not flash.empty?

    get root_path
    assert flash.empty?
  end

  test 'login with a valid name' do
    user = User.create(name: 'ballis', email: 'ballis@x.com', password: 'precious', password_confirmation: 'precious')
    get login_path
    user.update!(activated: true, activated_at: Time.zone.now)
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "ballis@x.com", password: "precious" }}
    assert_redirected_to user_path(user.id)
    follow_redirect!
    assert_template 'users/show'
    assert flash.empty?
  end

  test 'login with a fixture guy' do
    setup_feed_tree
    get login_path
    post login_path, params: { session: { email: @user.email, password: 'precious' }}
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
  end

  test 'and logout is ok' do
    get login_path
    post login_path, params: { session: { email: @user.email, password: 'precious' }}
    assert_redirected_to @user
    assert is_logged_in?
    delete logout_path
    assert !is_logged_in?
  end
  
  test 'login and out with a fixture guy' do
    setup_feed_tree
    get login_path
    post login_path, params: { session: { email: @user.email, password: 'precious' }}
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!

    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
    
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url

    # Simulate clicking logout in second window
    delete logout_path
    follow_redirect!
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end
  
  test 'login with remembering and forgetting' do
    get login_path
    post login_path, params: { session: { email: @user.email, password: 'precious', remember_me: 1 }}
    @user.reload
    assert_not_nil @user.remember_digest
    delete logout_path
    post login_path, params: { session: { email: @user.email, password: 'precious' }}
    @user.reload
    assert_nil @user.remember_digest
  end
  
  test 'login with remembering #2' do
    log_in_as(@user, password: 'precious', remember_me: '1')
    assert_equal 'Wally Dufois', assigns(:user).name
    assert_not_empty cookies['remember_token']
  end
  
  test 'login without remembering #2' do
    log_in_as(@user, password: 'precious', remember_me: '1')
    assert_not_empty cookies['remember_token']
    log_in_as(@user, password: 'precious', remember_me: '0')
    assert_empty cookies['remember_token']
  end

  
end
