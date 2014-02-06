require_relative './resource.rb'

module Radar
  class Client
    attr_accessor :subdomain

    def self.configure(&blk)
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
      @@redis_retriever.call(@subdomain) if defined?(@@redis_retriever) && @@redis_retriever
    end
  end
end
