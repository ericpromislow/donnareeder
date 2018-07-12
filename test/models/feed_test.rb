require 'test_helper'

class FeedTest < ActiveSupport::TestCase

  def setup
    @user = users(:wally)
    @node_guido = nodes(:guido)
    @node_brendon = nodes(:brendon)
    @feed_guido = feeds(:guido)
    @feed_guido.update!(node: @node_guido)
    @feed_brendon = feeds(:brendon)
    @feed_guido.update!(node: @node_guido)
    @feed_brendon.update!(node: @node_brendon)
  end

  test 'missing type should not be valid' do
    feed = Feed.new
    assert_not feed.valid?
  end

  test 'missing title should not be valid' do
    feed = Feed.new(feed_type:'rss')
    assert_not feed.valid?
  end

  test 'missing url should not be valid' do
    feed = Feed.new(feed_type:'rss', title:'t')
    assert_not feed.valid?
  end

  test 'needs to belong to a node' do
    feed = Feed.new(feed_type:'rss', title:'yop', xml_url:'x')
    assert !feed.valid?
  end

  test 'should be valid' do
    feed = Feed.new(feed_type:'rss', title:'yop', xml_url:'x', node:@node_guido)
    assert feed.valid?
  end
end
