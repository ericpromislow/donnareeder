ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include ApplicationHelper

  def is_logged_in?
    !session[:user_id].nil?
  end

  def log_in_as(user)
    session[:user_id] = user.id
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

  def setup_news_feed_tree
    @nodes_by_name = {}
    %i/news tech arts movies entertainment business nasa/.each do |name|
      @nodes_by_name[name] = nodes(name)
    end
    @nodes_by_name[:movies].update!(parent: @nodes_by_name[:arts])
    @nodes_by_name[:entertainment].update!(parent: @nodes_by_name[:arts])
    @nodes_by_name[:nasa].update!(parent: @nodes_by_name[:tech])
    ptn = /^(.*?)(\d+)$/
    File.open(File.expand_path("../../test/fixtures/feeds.yml", __FILE__)) do |fd|
      feeds_hash = YAML.load(fd.read).deep_symbolize_keys
    end
    feeds_hash.each do |name, feed|
      m = ptn.match(name.to_s)
      next if !m
      parent_node = @nodes_by_name[m[1].to_sym]
      if !parent_node
        $stderr.puts("Awp: can't find node #{m[1]} for feed #{name}")
        next
      end
      feed_node = Node.create(node_type: 'feed', user: user, parent: parent_node, position: parent_node.children.count + 1)
      Feed.create!(value.merge(node: feed_node))
    end
  end

end

class ActionDispatch::IntegrationTest
  def log_in_as(user, password: 'precious', remember_me: 1)
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me}}
  end
end
