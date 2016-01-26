require_relative './resource/resource.rb'

module Radar
  class LegacyClient
    attr_accessor :subdomain

    def self.redis_retriever_defined?
      defined?(@@redis_retriever) && @@redis_retriever
    end

    def self.define_redis_retriever(&blk)
      @@redis_retriever = blk
    end

    def initialize(subdomain)
      @subdomain = subdomain
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

    def redis
      @@redis_retriever.call(@subdomain) if Client.redis_retriever_defined?
    end
  end
end
