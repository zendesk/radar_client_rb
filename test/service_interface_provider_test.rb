require_relative './minitest_helper'
require_relative '../lib/radar_client_rb/service_interface_provider'
require_relative '../lib/radar_client_rb/message'
require 'faraday'

describe Radar::ServiceInterfaceProvider do
  let(:msg) { Radar::Message.new(op: 'get', to: 'status:/foo/bar', key: 'baz') }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:provider) {
    p = Radar::ServiceInterfaceProvider.new('http://localhost/radar/service')
    p.conn.builder.delete(p.conn.builder.handlers.find {|h| h.klass < Faraday::Adapter })
    p.conn.adapter :test, stubs
    p
  }
  it 'is initialized by endpoint' do
    assert_equal 'http://localhost/radar/service', provider.endpoint
  end

  describe 'process(message)' do
    it 'sends message as http post ServiceInterface request' do
      stubs.post('/radar/service', msg.to_json) { |env| [ 200, {}, '{"op":"foo"}' ]}
      provider.process(msg)
      stubs.verify_stubbed_calls
    end

    describe 'for HTTP status code' do
      describe '200' do
        let(:response_message) { Radar::Message.new(op: 'get', to: 'status:/foo/bar', key: 'baz', value: 'abc')}
        before do
          stubs.post('/radar/service', msg.to_json) { |env| [ 200, {}, response_message.to_json ]}
        end
        it 'returns response message' do
          
          response = provider.process(msg)
          assert_equal response_message, response
        end
      end

      describe '400' do
        let(:response_message) { Radar::Message.new(op: 'err')}
        before do
          stubs.post('/radar/service', msg.to_json) { |env| [ 400, {}, response_message.to_json ]}
        end
        it 'raises an error' do
          assert_raises RuntimeError do
            provider.process(msg)
          end
        end
      end
      describe '401' do
        let(:response_message) { Radar::Message.new(op: 'err')}
        before do
          stubs.post('/radar/service', msg.to_json) { |env| [ 401, {}, response_message.to_json ]}
        end
        it 'raises an auth error' do
          assert_raises RuntimeError do
            provider.process(msg)
          end
        end
      end
      describe '403' do
        let(:response_message) { Radar::Message.new(op: 'err')}
        before do
          stubs.post('/radar/service', msg.to_json) { |env| [ 403, {}, response_message.to_json ]}
        end
        it 'raises an auth error' do
          assert_raises RuntimeError do
            provider.process(msg)
          end
        end
      end
      describe '404' do
        let(:response_message) { Radar::Message.new(op: 'err')}
        before do
          stubs.post('/radar/service', msg.to_json) { |env| [ 404, {}, response_message.to_json ]}
        end
        it 'raises an error' do
          assert_raises RuntimeError do
            provider.process(msg)
          end
        end
      end
      describe '500' do
        let(:response_message) { Radar::Message.new(op: 'err')}
        before do
          stubs.post('/radar/service', msg.to_json) { |env| [ 500, {}, response_message.to_json ]}
        end
        it 'raises an error' do
          assert_raises RuntimeError do
            provider.process(msg)
          end
        end
      end
    end
  end

  describe 'middleware' do
    it 'adds faraday style middleware to each request' do
      middleware = ''
      arg = ''
      provider.use(middleware, arg)
    end
  end
end