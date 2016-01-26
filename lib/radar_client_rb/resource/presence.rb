require_relative './resource'

module Radar
  class Presence < Resource
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
end