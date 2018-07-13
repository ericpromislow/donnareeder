require 'test_helper'

class FeedsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:wally)
    @archer = users(:archer)
  end

  test 'anyone can list the feeds' do
    get feeds_path
    assert_equal 200, response.status
    assert_template 'feeds/index'
    assert_select 'ul.feeds li'
  end

  test 'anyone can see an article list for a feed' do
    feed = feeds(:tech1)
    get feed_path(feed)
    assert_equal 200, response.status
    stuff = JSON.parse(response.body)
    if stuff.size > 0
      assert_equal %w/link pubDate title feed_id guid/.sort, stuff[0].keys.sort
    end
  end

  test 'must login to create a feed' do
    post feeds_path, params: { feed: {feed_type: 'rss', xml_url: "http://www.economist.com/rss/" } }
    assert_not flash.empty?
    assert_redirected_to feeds_url
  end

  test 'must login to as an admin can create a feed' do
    log_in_as @archer
    post feeds_path, params: { feed: {feed_type: 'rss', xml_url: "http://www.economist.com/rss/" } }
    assert flash.empty?
    assert_redirected_to feeds_url
  end

  test 'admin can create a feed' do
    log_in_as @user
    node = nodes(:guido)
    post feeds_path, params: { feed: {feed_type: 'rss', xml_url: "http://www.economist.com/rss/", title:'mooha', node_id:node.id } }
    assert flash.empty?
    assert_redirected_to feeds_path
  end

end
