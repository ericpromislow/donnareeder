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

  test 'should belong to a user' do
    node = Node.new(node_type:'node')
    assert_not node.valid?
  end

  test 'should have a user' do
    node = Node.new(node_type:'node', user:@user)
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
    assert_equal(5, x1.count)

    # Root nodes
    x2 = @user.nodes.where(ancestry: nil)
    assert_equal(1, x2.count)
    x2 = x2.first
    assert_equal('languages', x2.title)
    assert_equal('node', x2.node_type)
    
    x3 = x2.subtree.arrange_serializable(order: :created_at)
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

  test 'it should destroy all the nodes associated with a user' do
    greenie = User.create!(name: 'greenie', email: 'g@a.com', password:'precious',  password_confirmation:'precious');
    node_count_1 = Node.count
    node1 = Node.create!(node_type: 'node', user: greenie, title: "top")
    node2 = Node.create!(node_type: 'node', user: greenie, title: "a1", parent:node1)
    node3 = Node.create!(node_type: 'feed', user: greenie, title: "a3", parent:node2, xmlUrl:'x')
    node4 = Node.create!(node_type: 'node', user: greenie, title: "a4", parent:node2)
    node_count_2 = Node.count
    assert_equal 4, node_count_2 - node_count_1
    greenie.destroy
    node_count_3 = Node.count
    assert_equal -4, node_count_3 - node_count_2
  end
    
end
