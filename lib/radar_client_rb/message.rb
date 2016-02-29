require 'json'

module Radar
  class Message
    attr_reader :op, :to, :key, :value, :options

    def initialize(op:, to: nil, key: nil, value: nil, options: nil)
      not_empty!(:op, op)

      @op = op
      @to = to
      @key = String(key)
      @value = value
      @options = options
    end

    def self.from_json(json)
      msg = JSON.parse(json)
      Message.new(op: msg['op'], to: msg['to'], value: msg['value'], key: msg['key'])
    end

    def to_json
      msg = {
        op: @op
      }

      msg[:to] = @to unless @to == nil
      msg[:key] = @key unless @key == nil || @key == ''
      msg[:value] = @value unless @value == nil
      msg[:options] = @options unless @options == nil || @options.size == 0

      JSON.generate(msg)
    end

    def to_s
      "Radar::Message: #{to_json}"
    end

    def merge(op: nil, to: nil, key: nil, value: nil)
      Message.new(op: op || @op, to: to || @to, key: key || @key, value: value || @value)
    end

    def ==(o)
      o.class == self.class && o.op == op && o.to == to && o.key == key && o.value == value && o.options == options
    end
    
    alias_method :eql?, :==

    def hash
      op.hash + to.hash + key.hash + value.hash
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
