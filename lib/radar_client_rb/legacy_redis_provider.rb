require_relative './message'

module Radar
  class LegacyRedisProvider
    def initialize(r)
      @redis = r
    end

    def process(message)
    
      if message.to.start_with?('status:/')
        if message.op == 'get'
          get_status(message)
        elsif message.op == 'set'
          set_status(message)
        end
      elsif message.to.start_with?('presence:/')
        if message.op == 'get'
          get_presence(message)
        else
          Message.new(op: message.op, to: message.to, value: {})
        end
      else
        raise 'unsupported resource type'
      end
    end

    private

    def get_status(message)
      raw = @redis.hget(message.to, message.key)
      result = raw ? JSON.parse(raw, :quirks_mode => true) : nil
      message.merge(value: result)
    end

    def set_status(message)
      @redis.multi do |redis|
        @redis.hset(message.to, message.key, message.value.to_json)
        @redis.expire(message.to, 12*60*60)
        @redis.publish(message.to, message.to_json)
      end

      client = @redis.respond_to?(:client) && @redis.client
      client_info = if client && client.respond_to?(:host) && client.respond_to?(:port)
        "Client: #{client.host}:#{client.port}"
      else
        "unknown"
      end
      # logger.debug "Set Status: #{key}, #{value}, #{client_info}"
      Message.new(op: 'ack', to: message.to)
    end

    def get_presence(message)
      clients = get_clients(message.to).select { |client| client['online'] }
      sentries = clients.map { |client| client['sentry'] }
      online_sentries = select_online_sentries(sentries)
      online_clients = clients.select { |client| online_sentries.include?(client['sentry']) }

      result = {}

      online_clients.each do |client|
        user_id = client['userId']
        result[user_id] ||= { :clients => {}, :userType => client['userType'] }
        result[user_id][:clients][client['clientId']] = client['userData'] || {}
      end

      message.merge(value: result)
    end

    def get_clients(scope)
      @redis.hgetall(scope).values.map { |value| JSON.parse(value) }
    end

    def select_online_sentries(sentry_ids)
      return [] unless sentry_ids && sentry_ids.any?
      online_sentries = @redis.hmget('sentry:/radar', *sentry_ids.uniq)
        .select { |x| !x.nil? }
        .map { |data| JSON.parse(data) }
        .select { |sentry| !is_expired?(sentry) }

      online_sentries.map { |sentry| sentry['name'] }
    end

    def is_expired?(item)
      !item['expiration'] || item['expiration'] <= (Time.now.to_i * 1000)
    end
  end
end
