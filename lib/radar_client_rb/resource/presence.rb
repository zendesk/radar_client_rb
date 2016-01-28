require_relative './resource'

module Radar
  class Presence < Resource
    def type
      'presence'
    end

    def get
      message = Message.new(op: 'get', to: @scope)
      response = provider.process(message)
      response.value
    end
  end
end
