require 'bundler/setup'
require 'bump/tasks'

task :default => [:test]

Dir.glob('./tasks/*.rake').each { |r| import r }
