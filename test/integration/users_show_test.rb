require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:wally)
    @archer = users(:archer)
    @lana = users(:lana)
  end

  test 'user should be able to see the feed-tree' do
    log_in_as @lana
    get user_path(@lana)
    assert_template 'users/show'
    assert_select 'div#feedTree section.feeds', count: 1
  end

  test 'admin should be able to delete a user' do
    log_in_as @user
    get user_path(@lana)
    assert_template 'users/show'
    assert_select 'a[data-method="delete"][href=?]', user_path, text: 'delete their account', count: 1
  end
end
