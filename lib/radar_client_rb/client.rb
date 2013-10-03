require_relative './resource.rb'

module Radar
  class Client
    attr_accessor :redis, :account_name, :user_id

    def initialize(redis, account_name, user_id)
      @redis = redis
      @account_name = account_name
      @user_id = user_id
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
