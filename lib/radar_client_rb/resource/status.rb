require_relative './resource'
require_relative '../message'

module Radar
  class Status < Resource
    def type
      'status'
    end

    def get(key)
      key = String(key)
      message = Message.new(op: 'get', to: @scope, key: key)
      response = process(message)
      response.value[key]
    end

    def set(key, value)
      message = Message.new(op: 'set', to: @scope, key: key, value: value)
      response = process(message)
      nil
    end
  end
end
