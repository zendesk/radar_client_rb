require 'faraday'
require_relative './message'

module Radar
  class ServiceInterfaceProvider
    attr_reader :endpoint

    def initialize(endpoint, adapter: Faraday.default_adapter)
      @endpoint = endpoint
      @adapter = adapter
      @middlewares = []
    end

    def use(middleware, arg)
      @middlewares.push [middleware, arg]
    end

    def process(message)
      if message.to.start_with?('status:/')
        if message.op == 'get'
          post_message(message)
        elsif message.op == 'set'
          post_message(message)
        end
      elsif message.to.start_with?('presence:/')
        if message.op == 'get'
          get_presence(message)
        else
          raise NotImplementedError
        end
      elsif message.to.start_with?('message:/')
          raise NotImplementedError
      else
        raise NotImplementedError
      end
    end

    def conn
      @c ||= Faraday.new(url: @endpoint) do |faraday|
        Radar::Client::log_debug "using m: #{@middlewares}"
        @middlewares.each { |m| faraday.request m[0], m[1] }        
        faraday.adapter @adapter
      end
      @c
    end

    private

    # send a radar message and await response
    def post_message(message)
      res = conn.post do |req|
        req.headers['Content-Type'] = 'application/json'
        # other auth headers would have to go here
        

        req.body = message.to_json
        Radar::Client::log_debug "req #{req.body}"
      end
      Radar::Client::log_debug "res #{res.status} #{res.body}"
      case res.status
        when 200
          Message.from_json res.body
        else
          raise RuntimeError
      end
    end

    def get_presence(message)
      post_message(message)
    end

  end
end
