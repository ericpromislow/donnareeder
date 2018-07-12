
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

97.times do |n|
  name  = Faker::Name.name
  email = name.sub(/\A\W*/, '').gsub(/\W+/, '.').downcase + '@' + Faker::Internet.domain_name
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end

user = User.find_by_name('a1')
File.open(File.expand_path("../../test/fixtures/nodes.yml", __FILE__)) do |fd|
  y = YAML.load(fd.read).deep_symbolize_keys
  node_languages = Node.create!(y[:languages].merge(user: user))
  node_python = Node.create!(y[:python].merge(user: user, parent: node_languages))
  node_javascript = Node.create!(y[:javascript].merge(user: user, parent: node_languages))
  node_guido = Node.create!(y[:guido].merge(user: user, parent: node_python))
  node_brendon = Node.create!(y[:brendon].merge(user: user, parent: node_javascript))
end
