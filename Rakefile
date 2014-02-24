require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:unit)

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:integration)

namespace :travis do
  desc 'Run the tests on Travis'
  task :ci => [:unit, :integration]
end
