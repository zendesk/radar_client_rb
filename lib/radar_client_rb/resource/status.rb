require_relative './resource'

module Radar
  class Status < Resource
    def type
      'status'
    end

    def get(key)
      result = @client.redis.hget(@name, key)
      result ? JSON.parse(result, :quirks_mode => true) : nil
    end

    def set(key, value)
      redis = @client.redis
      redis.multi do |redis|
        redis.hset(@name, key, value.to_json)
        redis.expire(@name, 12*60*60)
        redis.publish(@name, { :to => @name, :op => 'set', :key => key, :value => value }.to_json)
      end

      client = redis.respond_to?(:client) && redis.client
      client_info = if client && client.respond_to?(:host) && client.respond_to?(:port)
        "Client: #{client.host}:#{client.port}"
      else
        "unknown"
      end
      logger.debug "Set Status: #{key}, #{value}, #{client_info}"
    end
  end
end
