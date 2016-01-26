require_relative '../../minitest_helper'
require_relative '../../../lib/radar_client_rb/service_client'

describe Radar::ServiceClient do
  let(:provider) { {} }
  let(:client) { Radar::ServiceClient.new(provider, 'account') }

  it 'can be instantiated' do
    assert_instance_of Radar::ServiceClient, client
    assert_equal 'account', client.subdomain
    assert_equal provider, client.provider
  end

  describe '#status' do
    it 'returns a configured status object' do
      status = client.status('foo')
      assert_instance_of Radar::Status, status
      assert_equal client, status.client
      assert_equal 'status:/account/foo', status.scope
    end
  end

  describe '#presence' do
    it 'returns a configured presence object'
  end
  
  describe '#message' do
    it 'returns a configured message list object'
  end
end
