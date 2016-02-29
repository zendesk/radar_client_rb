require_relative './resource/status'
require_relative './resource/presence'
require_relative './resource/message_list'

module Radar
  class ServiceClient
    attr_reader :provider, :subdomain

    def initialize(provider, subdomain)
      @provider = provider
      @subdomain = subdomain
    end

    def status(name)
      Status.new(self, name)
    end

    def presence(name)
      Presence.new(self, name)
    end

    def message(name)
      MessageList.new(self, name)
    end
  end
end
