module UsersHelper
  def item_num(paginated_thing, index)
    (paginated_thing.current_page.to_i - 1) * (paginated_thing.per_page) + index
  end

  def get_label(node)
    %w/title description htmlUrl xmlUrl/.each do |name|
      return sanitize(node[name]) if node[name].present?
    end
    "?"
  end

  def get_attrs(node)
    attrs = {}
    %w/feed_type title description xmlUrl htmlUrl/.each do |name|
      attrs[name] = sanitize(node[name]) if node[name].present?
    end
    attrs
  end

  def dump_the_list(node)
    results = []
    dump_the_list_aux(node, results)
    raw(results.join(''))
  end

  def dump_the_list_aux(node, results)
    tree = node.subtree.arrange_serializable(order: :created_at)
    attrs = get_attrs(node).merge(class: node['node_type']).map{|k, v| %Q[#{k}="#{v}"]}.join(" ")
    if node['node_type'] == 'feed'
      results << %Q[<li #{attrs}>#{get_label(node)}</li>\n]
    else
      results << %Q[<li #{attrs}>\n]
      results << %Q[<ul class="ul-nodelist">\n]
      node.children.each do |subnode|
        dump_the_list_aux(subnode, results)
      end
      results << %Q[</ul>\n]
      results << %Q[</li>\n]
    end
  end

end
