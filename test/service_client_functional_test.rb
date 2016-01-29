require_relative './minitest_helper'
require_relative '../lib/radar_client_rb/service_client.rb'

describe Radar::ServiceClient do
  let(:mock_provider) { mock('provider') }
  let(:subdomain) { 'account' }
  let(:client) { Radar::ServiceClient.new(mock_provider, subdomain) }
  let(:scope) { 'scope1' }
  let(:user_id1) { 123 }
  let(:user_id2) { 456 }

  it 'can be instantiated' do
    assert client
  end

  it 'can get all three resources' do
    assert_instance_of Radar::Presence, client.presence('foo')
    assert_instance_of Radar::Status, client.status('foo')
    assert_instance_of Radar::MessageList, client.message('foo')
  end

  describe 'presence' do
    it 'can retrieve a presence'
  end

  describe 'status' do
    let(:full_scope) { "status:/#{subdomain}/#{scope}" }
    let(:status1) { 'status1' }
    let(:status2) { { 'hello' => 'world' } }
    let(:msg) { Radar::Message.new(op: 'op', to: 'to')}

    it 'can retrieve a status' do
      mock_provider.expects(:process)
        .with() { |m| m == Radar::Message.new(op: 'get', to: full_scope, key: user_id1) }
        .returns(msg.merge(value: status1))

      assert_equal status1, client.status(scope).get(user_id1)
    end

    it 'can set a status' do
      mock_provider.expects(:process)
        .with() { |m| m == Radar::Message.new(op: 'set', to: full_scope, key: user_id2, value: {state: 'updated'}) }
        .returns(msg.merge(op: 'ack'))

      client.status(scope).set(user_id2, {state: 'updated'})
    end
  end

end
