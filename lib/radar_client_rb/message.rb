require 'json'

module Radar
  class Message
    attr_reader :op, :to, :key, :value

    def initialize(op:, to:, value: nil, key: nil)
      not_empty!(:op, op)
      not_empty!(:to, to)

      @op = op
      @to = to
      @key = key
      @value = value
    end

    def self.from_json(json)
      msg = JSON.parse(json)
      Message.new(op: msg['op'], to: msg['to'], value: msg['value'], key: msg['key'])
    end

    def to_json
      msg = {
        op: @op,
        to: @to
      }

      msg[:key] = @key unless @key == nil
      msg[:value] = @value unless @value == nil
      
      JSON.generate(msg)
    end

    def to_s
      "Radar::Message: #{to_json}"
    end

    private 

    def not_empty!(param, value)
      raise ArgumentError, "#{param} must not be nil or empty" unless !value.nil? && !value.empty?
    end

    def blank?(value)
      value.nil? || value == ''
    end
  end
end
