require_relative './resource.rb'

module Radar
  class Client
    attr_accessor :redis, :account_name, :user_id

    def self.configure(&blk)
      @@redis_retriever = blk
    end

    def initialize(account_name)
      @account_name = account_name
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
      @@redis_retriever.call(@account_name) if defined?(@@redis_retriever) && @@redis_retriever
    end
  end
end
