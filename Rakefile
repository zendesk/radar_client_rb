require 'bundler/setup'
require 'bump/tasks'
require 'bundler/gem_tasks'

task :default => [:test]

Dir.glob('./tasks/*.rake').each { |r| import r }
