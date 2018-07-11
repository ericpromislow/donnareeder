
password = "precious"

3.times do |n|
  name  = "a#{n + 1}"
  email = "#{name}@a.com"
  User.create!(name:  name,
               email: email,
               admin: true,
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
