require_relative './resource'

module Radar
  class MessageList < Resource
    def type
      'message'
    end

    def get
      message = Message.new(op: 'get', to: @scope)
      response = process(message)
      response.value
    end
  end
end
