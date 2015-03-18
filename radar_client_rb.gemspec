require_relative 'lib/radar_client_rb/version'

Gem::Specification.new "radar_client_rb", Radar::Client::VERSION do |gem|
  gem.authors = ["Patrick O'Brian", "Ciaran Archer", "Vanchi K"]
  gem.email = "radar@zendesk.com"
  gem.homepage = "http://github.com/zendesk/radar_client_rb"
  gem.summary = gem.description = "Read/Write Radar Resources from Redis through Ruby"
  gem.files = Dir.glob("lib/**/*")

  gem.add_runtime_dependency("redis")

  gem.add_development_dependency("rake")
  gem.add_development_dependency("minitest")
  gem.add_development_dependency("fakeredis")
  gem.add_development_dependency("mocha")
  gem.add_development_dependency("private_gem")
  gem.add_development_dependency("bump")
end
