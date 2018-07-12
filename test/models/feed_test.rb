require 'test_helper'

class FeedTest < ActiveSupport::TestCase

  def setup
    @user = users(:wally)
    @node_guido = nodes(:guido)
    @node_brendon = nodes(:brendon)
    @feed_guido = feeds(:guido)
    @feed_guido.update!(parent: @node_guido)
    @feed_brendon = feeds(:brendon)
    @feed_guido.update!(parent: @node_guido)
    @feed_brendon.update!(parent: @node_brendon)
  end

  test 'missing type should not be valid' do
    node = Node.new
    assert_not node.valid?
  end

  test 'missing title should not be valid' do
    node = Node.new(type:'rss')
    assert_not node.valid?
  end

  test 'should be valid' do
    node = Node.new(type:'rss', title:'yop')
    assert node.valid?
  end
end
