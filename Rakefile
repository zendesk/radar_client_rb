require 'bundler/setup'
require 'bump/tasks'
require 'bundler/gem_tasks'

# Pushing to rubygems is handled by a github workflow
ENV['gem_push'] = 'false'

task :default => [:test]

Dir.glob('./tasks/*.rake').each { |r| import r }
