module UsersHelper
  def item_num(paginated_thing, index)
    (paginated_thing.current_page.to_i - 1) * (paginated_thing.per_page) + index
  end

  def get_label(node)
    if node.node_type == 'node'
      return sanitize(node.title)
    else
      feed = node.feed
      %w/title description html_url xml_url/.each do |name|
        return sanitize(feed[name]) if feed[name].present?
      end
    end
    "?"
  end

  def get_attrs(node)
    attrs = {}
    %w/feed_type title description xml_url html_url/.each do |name|
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
    tree = node.subtree.arrange_serializable(order: :position)
    attrs = get_attrs(node).merge(class: node.node_type).map{|k, v| %Q[#{k}="#{v}"]}.join(" ")
      results << %Q[<li #{attrs}>#{get_label(node)}]
    if node.node_type == 'feed'
      results << %Q[</li>\n]
    else
      results << %Q[\n]
      results << %Q[<ul class="ul-nodelist">\n]
      node.children.each do |subnode|
        dump_the_list_aux(subnode, results)
      end
      results << %Q[</ul>\n]
      results << %Q[</li>\n]
    end
  end

end
