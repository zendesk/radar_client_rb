require 'logger'

module Radar
  class Resource
    def initialize(client, name)
      @client = client
      @name = name
    end

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new($stdout)
    end
  end

  class Presence < Resource
    def initialize(client, name)
      super(client, "presence:/#{client.subdomain}/#{name}")
    end

    def get
      result = {}
      forty_five_seconds_ago = (Time.now.to_i - 45) * 1000
      @client.redis.hgetall(@name).each do |key, value|
        user_id, client_id = key.split('.')
        message = JSON.parse(value)
        if message['online'] && message['at'] > forty_five_seconds_ago
          result[user_id] ||= { :clients => {}, :userType => message['userType'] }
          result[user_id][:clients][client_id] = message['userData'] || {}
        end
      end
      result
    end
  end

  class Status < Resource
    def initialize(client, name)
      super(client, "status:/#{client.subdomain}/#{name}")
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


  class MessageList < Resource
    def initialize(client, name)
      super(client, "message:/#{client.subdomain}/#{name}")
    end

    def get
      # Unfortunately we can't apply any maxAge policies.
      result_arr = @client.redis.zrange(@name, -100, -1, :with_scores => true)
      result = []
      result_arr.each do |message_json, time|
        message = JSON.parse(message_json, :quirks_mode => true)
        result << [message, time]
      end
      result
    end
  end
end
