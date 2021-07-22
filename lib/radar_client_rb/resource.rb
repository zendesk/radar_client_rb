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

      clients = get_clients.select { |client| client['online'] }
      sentries = clients.map { |client| client['sentry'] }
      online_sentries = select_online_sentries(sentries)
      online_clients = clients.select { |client| online_sentries.include?(client['sentry']) }

      online_clients.each do |client|
        user_id = client['userId']
        result[user_id] ||= { :clients => {}, :userType => client['userType'] }
        result[user_id][:clients][client['clientId']] = client['userData'] || {}
      end
      result
    end

    private

    def get_clients
      @client.redis.hgetall(@name).values.map { |value| JSON.parse(value) }
    end

    def select_online_sentries(sentry_ids)
      return [] unless sentry_ids && sentry_ids.any?
      online_sentries = @client.redis.hmget('sentry:/radar', *sentry_ids.uniq)
        .select { |x| !x.nil? }
        .map { |data| JSON.parse(data) }
        .select { |sentry| !message_is_expired?(sentry) }

      online_sentries.map { |sentry| sentry['name'] }
    end

    def message_is_expired?(message)
      !message['expiration'] || message['expiration'] <= (Time.now.to_i * 1000)
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

      client = redis.respond_to?(:client) && redis.connection
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
