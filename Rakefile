# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task :rubocop do
  require 'rubocop'
  cli = RuboCop::CLI.new
  exit_code = cli.run(%w(app lib test --auto-correct))
  exit(exit_code) if exit_code != 0
end
