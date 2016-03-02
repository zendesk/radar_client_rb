require 'minitest/autorun'
require 'mocha/setup'

Radar::Client.logger.level = 5 unless ENV['VERBOSE']
