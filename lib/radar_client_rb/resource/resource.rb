require 'logger'

module Radar
  class Resource
    attr_reader :client, :scope
    def initialize(client, name)
      @client = client
      @name = name
      @scope = build_scope(name)
    end

    def type
      nil
    end

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new($stdout)
    end

    private
    def build_scope(name)
      "#{type}:/#{@client.subdomain}/#{name}"
    end

    def provider
      @client.provider
    end
  end
end
