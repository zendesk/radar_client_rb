require 'minitest/autorun'
require 'radar_client_rb'
require 'mocha/setup'

describe Radar::Client do
  let(:subdomain) { 'support' }
  let(:scope) { 'scope1' }
  let(:client) { Radar::Client.new(subdomain) }

  it 'can be instantiated' do
    assert client
  end

  it 'can get all three resources' do
    assert_instance_of Radar::Presence, client.presence('test')
    assert_instance_of Radar::Status, client.status('test')
    assert_instance_of Radar::MessageList, client.message('test')
  end
end
