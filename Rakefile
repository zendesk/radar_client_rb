require 'bundler/setup'
require "private_gem/tasks"

task :default => [:test]

Dir.glob('./tasks/*.rake').each { |r| import r }
