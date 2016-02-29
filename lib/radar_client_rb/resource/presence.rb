require_relative './resource'

module Radar
  class Presence < Resource
    def type
      'presence'
    end

    def get
      message = Message.new(op: 'get', to: @scope, options: {version: 2})
      response = process(message)
      response.value
    end
  end
end
