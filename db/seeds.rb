password = "precious"

3.times do |n|
  name  = "a#{n + 1}"
  email = "#{name}@a.com"
  User.create!(name:  name,
               email: email,
               admin: true,
               activated: true,
               activated_at: Time.zone.now,
               password:              password,
               password_confirmation: password)
end

2.times do |n|
  name  = Faker::Name.name
  email = name.sub(/\A\W*/, '').gsub(/\W+/, '.').downcase + '@' + Faker::Internet.domain_name
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end

nodes = feeds = nil
File.open(File.expand_path("../../test/fixtures/nodes.yml", __FILE__)) do |fd|
  nodes = YAML.load(fd.read).deep_symbolize_keys
end
File.open(File.expand_path("../../test/fixtures/feeds.yml", __FILE__)) do |fd|
  feeds = YAML.load(fd.read).deep_symbolize_keys
end

user = User.find_by_name('a1')
node_languages = Node.create!(nodes[:languages].merge(user: user))
node_python = Node.create!(nodes[:python].merge(user: user, parent: node_languages))
node_javascript = Node.create!(nodes[:javascript].merge(user: user, parent: node_languages))
node_guido = Node.create!(nodes[:guido].merge(user: user, parent: node_python))
node_brendon = Node.create!(nodes[:brendon].merge(user: user, parent: node_javascript))
Feed.create!(feeds[:guido].merge(node: node_guido))
Feed.create!(feeds[:brendon].merge(node: node_brendon))

user = User.find_by_name('a2')
nodes_by_name = {}
%i/news tech arts movies entertainment business/.each do |name|
  nodes_by_name[name] = Node.create!(nodes[name].merge(user: user))
end

nodes_by_name[:movies].update!(parent: nodes_by_name[:arts], user:user)
nodes_by_name[:entertainment].update!(parent: nodes_by_name[:arts], user:user)
ptn = /^(.*?)(\d+)$/
feeds.each do |name, value|
  m = ptn.match(name.to_s)
  next if !m
  parent_node = nodes_by_name[m[1].to_sym]
  if !parent_node
    $stderr.puts("Awp: can't find node #{m[1]} for feed #{name}")
    next
  end
  feed_node = Node.create(node_type: 'feed', user: user, parent: parent_node, position: parent_node.children.count + 1)
  Feed.create!(value.merge(node: feed_node))
end

