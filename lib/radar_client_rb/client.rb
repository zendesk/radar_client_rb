require_relative './legacy_client.rb'

# Backwards compatibility with 1.0.4
Radar::Client = Radar::LegacyClient

module Radar
  class Client
    def self.logger
      @logger ||= if const_defined?("Rails")
        Rails.logger
      elsif const_defined?("ActiveRecord")
        ActiveRecord::Base.logger
      else
        Logger.new(STDOUT)
      end
    end

    def self.log(message)
      logger.info("Radar::Client #{message}")
    end
    def self.log_debug(message)
      logger.debug("Radar::Client #{message}")
    end
  end
end
