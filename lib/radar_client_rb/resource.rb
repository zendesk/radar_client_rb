require "uri"

module Radar
  class Resource
    TYPE = "default"

    attr_accessor :client, :name

    def initialize(client, scope)
      @client = client
      @name = "#{self.class::TYPE}:/#{client.options[:accountName]}/#{scope}"
    end

    def get
      client.request({
        :to => name,
        :op => :get,
      })
    end

    def set(key, value)
      client.request({
        :to    => name,
        :op    => :set,
        :key   => key,
        :value => value,
      })
    end

    def sync(url)
      return false if !valid_url?(url)
      client.request({
        :to  => name,
        :op  => :sync,
        :url => url,
      })
    end

    def subscribe(url)
      return false if !valid_url?(url)
      client.request({
        :to  => name,
        :op  => :subscribe,
        :url => url,
        :ack => true,
      })["op"] == "ack"
    end

    # use the same client that you used to subscribe
    # or assign the client.id to the old client's id
    # in order for this to work as expected
    # otherwise this does not accomplish much
    def unsubscribe
      client.request({
        :to     => name,
        :op     => :unsubscribe,
        :ack    => true,
      })["op"] == "ack"
    end

    protected

    def valid_url?(url)
      uri = URI(url)
      uri.scheme && uri.host
      rescue
      false
    end
  end

  class Status < Resource
    TYPE = "status"

    def get(key=nil)
      result = super()
      return result[key] || {} if key
      result
    end
  end

  class Presence < Resource
    TYPE = "presence"
  end

  class MessageList < Resource
    TYPE = "message"
  end
end
