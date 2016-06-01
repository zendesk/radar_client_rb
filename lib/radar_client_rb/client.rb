require_relative './resource.rb'

module Radar
  class Client
    attr_accessor :subdomain, :redis

    def initialize(subdomain, redis)
      @subdomain = subdomain
      @redis = redis
    end

    def presence(name)
      Presence.new(self, name)
    end

    def status(name)
      Status.new(self, name)
    end

    def message(name)
      MessageList.new(self, name)
    end
  end
end
