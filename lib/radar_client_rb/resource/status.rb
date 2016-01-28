require_relative './resource'
require_relative '../message'

module Radar
  class Status < Resource
    def type
      'status'
    end

    def get(key)
      message = Message.new(op: 'get', to: @scope, key: key)
      response = provider.process(message)
      response.value
    end

    def set(key, value)
      message = Message.new(op: 'set', to: @scope, key: key, value: value)
      response = provider.process(message)
      nil
    end
  end
end
