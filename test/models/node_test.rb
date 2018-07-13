require 'test_helper'

class NodeTest < ActiveSupport::TestCase
  def setup
    @user = users(:wally)
    @node_languages = nodes(:languages)
    @node_python = nodes(:python)
    @node_javascript = nodes(:javascript)
    @node_guido = nodes(:guido)
    @node_brendon = nodes(:brendon)
  end

  test 'bad type should not be valid' do
    node = Node.new(node_type:'gortz')
    assert_not node.valid?
  end

  test 'needs a title' do
    node = Node.new(node_type:'node')
    assert_not node.valid?
  end

  test 'should belong to a user' do
    node = Node.new(node_type:'node', title:'t')
    assert_not node.valid?
  end

  test 'should accept a node' do
    node = Node.new(node_type:'node', user:@user, title:'stuff')
    assert node.valid?
  end

  test 'should see a tree' do
    @node_brendon.update!(parent: @node_javascript)
    @node_guido.update!(parent: @node_python)
    @node_python.update!(parent: @node_languages)
    @node_javascript.update!(parent: @node_languages)
    x1 = @user.nodes
    assert_equal(12, x1.count)

    # Root nodes
    x2 = @user.nodes.where(ancestry: nil)
    assert_equal(8, x2.count)
    language_node = x2.find {|x| x['title'] == 'languages' }
    assert_not_nil language_node
    assert_equal('node', language_node.node_type)
    
    x3 = language_node.subtree.arrange_serializable(order: :created_at)
    assert_equal x3[0]['id'], @node_languages.id
    assert_equal x3[0]['children'].size, 2
    children = x3[0]['children']
    idx = children[0]['title'] == 'javascript' ? 0 : 1
    py_idx = 1 - idx
    js_idx = idx
    assert_equal children[py_idx]['id'], @node_python.id
    assert_equal children[js_idx]['id'], @node_javascript.id
    assert_equal children[py_idx]['children'].size, 1
    assert_equal children[py_idx]['children'][0]['id'], @node_guido.id
    assert_equal children[js_idx]['children'].size, 1
    assert_equal children[js_idx]['children'][0]['id'], @node_brendon.id
  end

  test 'it should destroy all the nodes associated with a user but not the feeds' do
    greenie = User.create!(name: 'greenie', email: 'g@a.com', password:'precious',  password_confirmation:'precious');
    node_count_1 = Node.count
    feed_count_1 = Feed.count
    node1 = Node.create!(node_type: 'node', user: greenie, title: "top")
    node2 = Node.create!(node_type: 'node', user: greenie, title: "a1", parent:node1)
    node3 = Node.create!(node_type: 'feed', user: greenie, parent:node2)
    node4 = Node.create!(node_type: 'feed', user: greenie, parent:node2)
    node5 = Node.create!(node_type: 'node', user: greenie, title: "a4", parent:node2)
    feed1 = Feed.create!(feed_type:'rss', title:'yop', xml_url:'x', node:node3)
    feed2 = Feed.create!(feed_type:'rss', title:'yop', xml_url:'y', node:node3)
    node_count_2 = Node.count
    assert_equal 5, node_count_2 - node_count_1
    feed_count_2 = Feed.count
    assert_equal 2, feed_count_2 - feed_count_1
    greenie.destroy
    node_count_3 = Node.count
    feed_count_3 = Feed.count
    assert_equal -5, node_count_3 - node_count_2
    assert_equal feed_count_3, feed_count_2
  end
    
end
