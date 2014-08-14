require_relative './resource.rb'
require 'faraday'
require 'json'

module Radar
  class Client
    attr_accessor :options, :client_id

    def initialize(options)
      self.options = {
        :userId      => 0,
        :userType    => 0,
        :accountName => '',
      }.merge(options)
    end

    def presence(name)
      Presence.new(self, name)
    end

    def status(name)
      Status.new(self, name)
    end

    def message(name)
      MessageList.new(self, name)
    end

    def auth(message)
      message.merge(options)
    end

    def request(message)
      response = post(auth(message))

      self.client_id ||= response.headers['X-RADAR-ID']

      JSON.parse(response.body) rescue {}
    end

    def radar_url
      'http://localhost:10001/api'
    end

    def post(message)
      connection = Faraday.new(:url => radar_url) do |faraday|
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      connection.post do |request|
        request.headers['Content-Type'] = 'application/json'
        request.headers['X-RADAR-ID'] = client_id if client_id
        request.body = message.to_json
      end
    end
  end
end
