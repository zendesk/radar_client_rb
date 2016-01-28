require_relative './resource'

module Radar
  class MessageList < Resource
    def type
      'message'
    end

    def get
      # Unfortunately we can't apply any maxAge policies.
      result_arr = @client.redis.zrange(@scope, -100, -1, :with_scores => true)
      result = []
      result_arr.each do |message_json, time|
        message = JSON.parse(message_json, :quirks_mode => true)
        result << [message, time]
      end
      result
    end
  end
end
