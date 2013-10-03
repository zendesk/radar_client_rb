lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'radar_client_rb/version'

Gem::Specification.new do |gem|
  gem.name = 'radar_client_rb'
  gem.version = Radar::Client::VERSION
  gem.files = Dir["lib/**/*"] + %w(README.md)
  gem.summary = "Read/Write Radar Resources from Redis through Ruby"
  gem.description = gem.summary
  gem.email = "dev@zendesk.com"
  gem.homepage = "http://github.com/zendesk/radar_client_rb"
  gem.authors = ["Ciaran Archer", "Sam Shull", "Vanchi K"]
  gem.test_files = []
  gem.require_paths = [".", "lib"]
  gem.has_rdoc = 'false'
  gem.specification_version = 2
  gem.require_paths = ["lib"]

  gem.add_dependency("redis")
  gem.add_development_dependency("rake")
  gem.add_development_dependency("minitest")
  gem.add_development_dependency("fakeredis")
  gem.add_development_dependency("mocha")
end
