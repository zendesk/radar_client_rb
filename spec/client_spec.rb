require 'minitest/autorun'
require 'radar_client_rb'
require 'redis'
require 'mocha/setup'

describe Radar::Client do
  let(:user_id1) { 123 }
  let(:user_id2) { 456 }
  let(:user_id4) { 100 }
  let(:user_id5) { 200 }
  let(:user_id6) { 868 }
  let(:client_id1) { 'X2j7TjMTYWIz33vLABNW' }
  let(:client_id2) { 'Pl3kjj9d02PLsKNXlKSG' }
  let(:client_id3) { 'lkjasdiHJKSAHDIUHkJS' }
  let(:client_id4) { 'asdkjalsdkjaksdhasdk' }
  let(:client_id5) { 'asjkdhuiajahsdiuhajk' }
  let(:client_id6) { 'FfJcrX9qt_w5a3X_AAAM' }
  let(:client_id7) { 'MAAA_X3a5w_tq9XrcJfF' }
  let(:sentry_ok_id) { '0a93bab00bdb932' }
  let(:sentry_expired_id) { '239bdb00bab39a0' }
  let(:sentry_missing_id) { '239bdb000bdb932' }
  let(:subdomain) { 'support' }
  let(:scope) { 'scope1' }
  let(:redis_client) { Redis.new(url: ENV.fetch('REDIS_URL')) }
  let(:client) { Radar::Client.new(subdomain, redis_client) }
  let(:redis_sentries_key) { 'sentry:/radar' }

  it 'can be instantiated' do
    assert client
  end

  it 'can get all three resources' do
    assert_instance_of Radar::Presence, client.presence('test')
    assert_instance_of Radar::Status, client.status('test')
    assert_instance_of Radar::MessageList, client.message('test')
  end

  describe "presence" do
    let(:key) { "presence:/#{subdomain}/#{scope}" }
    let(:presence1) do
      {
        :userId => user_id1,
        :userType => 2,
        :userData => 'userData1',
        :clientId => client_id1,
        :online => true,
        :sentry => sentry_ok_id
      }
    end
    let(:presence2) do
      {
        :userId => user_id2,
        :userType => 4,
        :userData => 'userData2',
        :clientId => client_id2,
        :online => true,
        :sentry => sentry_ok_id
      }
    end
    let(:presence3) do
      {
        :userId => user_id1,
        :userType => 2,
        :userData => 'userData3',
        :clientId => client_id3,
        :online => true,
        :sentry => sentry_ok_id
      }
    end
    let(:client_offline) do
      {
        :userId => user_id4,
        :userType => 4,
        :userData => 'userData4',
        :clientId => client_id4,
        :online => false,
        :sentry => sentry_ok_id
      }
    end
    let(:client_missing_sentry) do
      {
        :userId => user_id5,
        :userType => 2,
        :userData => 'userData5',
        :clientId => client_id5,
        :online => true,
        :sentry => sentry_missing_id
      }
    end
    let(:client_expired_sentry) do
      {
        :userId => user_id6,
        :userType => 2,
        :userData => 'userData6',
        :clientId => client_id6,
        :online => true,
        :sentry => sentry_expired_id
      }
    end
    let(:presence7) do
      {
        :userId => user_id6,
        :userType => 2,
        :userData => 'userData7',
        :clientId => client_id7,
        :online => true,
        :sentry => sentry_missing_id
      }
    end
    let(:sentry_ok) do
      {
        :name => sentry_ok_id,
        :expiration => (Time.now.to_i + 100) * 1000,
        :host => "precise64",
        :port => "8000"
      }
    end
    let(:sentry_expired) do
      {
        :name => sentry_expired_id,
        :expiration => (Time.now.to_i - 100) * 1000,
        :host => "precise64",
        :port => "8000"
      }
    end

    before do
      redis_client.flushdb
      redis_client.hset(key, key_for_presence(presence1), presence1.to_json)
      redis_client.hset(key, key_for_presence(presence2), presence2.to_json)
      redis_client.hset(key, key_for_presence(presence3), presence3.to_json)
      redis_client.hset(key, key_for_presence(client_offline), client_offline.to_json) # offline
      redis_client.hset(key, key_for_presence(client_expired_sentry), client_expired_sentry.to_json) # sentry expired
      redis_client.hset(key, key_for_presence(presence7), presence7.to_json) # sentry offline

      redis_client.hset(redis_sentries_key, sentry_ok_id, sentry_ok.to_json)
      redis_client.hset(redis_sentries_key, sentry_expired_id, sentry_expired.to_json)
    end

    after do
      redis_client.del(key)
    end

    it 'can retrieve a presence' do
      result = {
         user_id1 => {
            :clients => {
               client_id1 =>"userData1",
               client_id3 =>"userData3" },
             :userType=>2 },
         user_id2 =>{
            :clients => {
               client_id2 =>"userData2" },
            :userType=>4 }
      }
      assert_equal result, client.presence(scope).get
    end

    it 'returns clients belonging to valid sentries' do
      redis_client.del(key)
      redis_client.del(redis_sentries_key)

      redis_client.hset(key, key_for_presence(presence1), presence1.to_json)
      redis_client.hset(redis_sentries_key, sentry_ok_id, sentry_ok.to_json)

      expected = {
        user_id1 => {
          :clients => {
            client_id1 =>"userData1"
          },
          :userType => 2
        }
      }

      assert_equal expected, client.presence(scope).get
    end

    it 'does not return clients belonging to missing sentries' do
      redis_client.del(key)
      redis_client.hset(key, key_for_presence(client_missing_sentry), client_missing_sentry.to_json)

      assert_equal client.presence(scope).get, {}
    end

    it 'does not return clients belonging to expired sentries' do
      redis_client.del(key)
      redis_client.hset(key, key_for_presence(client_expired_sentry), client_expired_sentry.to_json)

      assert_equal client.presence(scope).get, {}
    end
    it 'does not return clients which are offline' do
      redis_client.del(key)
      redis_client.hset(key, key_for_presence(client_offline), client_offline.to_json)

      assert_equal client.presence(scope).get, {}
    end

    it 'does not crash if the key does not exist' do
      assert_equal client.presence('nonexistant').get, {}
    end
  end

  def key_for_presence(presence)
    "#{presence[:userId]}.#{presence[:clientId]}"
  end

  describe "status" do
    let(:key) { "status:/#{subdomain}/#{scope}" }
    let(:status1) { 'status1' }
    let(:status2) { { 'hello' => 'world' } }

    before do
      redis_client.hset(key, user_id1, status1.to_json)
      redis_client.hset(key, user_id2, status2.to_json)
    end

    after do
      redis_client.del(key)
    end

    it 'can retrieve a status' do
      assert_equal client.status(scope).get(user_id1), status1
      assert_equal client.status(scope).get(user_id2), status2
      assert_nil client.status(scope).get(user_id4)
      assert_nil client.status('inexistant').get('non-key')
    end

    it 'can set a status' do
      client.status(scope).set(user_id4, { :state => 'updated' })
      assert_equal redis_client.hget(key, user_id4), { :state => 'updated' }.to_json
      assert_in_delta 12*60*60, redis_client.ttl(key), 3
    end
  end

  describe 'message' do
    let(:key) { "message:/#{subdomain}/#{scope}" }
    let(:message1) { 'message 1' }
    let(:message2) { { 'hello' => 'world' } }

    it 'can retrieve messages' do
      124.times do |i|
        redis_client.zadd(key, i, "message_#{i}".to_json)
      end
      expected = (24..123).map { |i| ["message_#{i}", i] }
      assert_equal expected, client.message(scope).get
    end
    it 'does not crash on nonexistant keys' do
      assert_equal client.message('nonexistant').get, []
    end
  end
end
