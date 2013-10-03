module Radar
  class Resource
    def initialize(client, name)
      @client = client
      @name = name
    end
  end

  class Presence < Resource
    def initialize(client, name)
      super(client, "presence:/#{client.account_name}/#{name}")
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
      super(client, "status:/#{client.account_name}/#{name}")
    end

    def get(key)
      result = @client.redis.hget(@name, key)
      result ? JSON.parse(result, :quirks_mode => true) : nil
    end

    def set(key, value)
      @client.redis.hset(@name, key, value.to_json)
      @client.redis.publish(@name, { :to => @name, :key => key, :value => value }.to_json)
    end
  end


  class MessageList < Resource
    def initialize(client, name)
      super(client, "message:/#{client.account_name}/#{name}")
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
