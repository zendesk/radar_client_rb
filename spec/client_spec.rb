require 'minitest/autorun'
require 'radar_client_rb'
require 'fakeredis'
require 'mocha/setup'

describe Radar::Client do
  let(:fakeredis) { FakeRedis::Redis.new }
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
  let(:sentry_id1) { '0a93bab00bdb932' }
  let(:sentry_id2) { '239bdb00bab39a0' }
  let(:sentry_id3) { '239bdb000bdb932' }
  let(:subdomain) { 'support' }
  let(:scope) { 'scope1' }
  let(:client) { Radar::Client.new(subdomain) }
  let(:redis_sentries_key) { 'sentry:/radar' }

  before do
    Radar::Client.define_redis_retriever do |subdomain|
      fakeredis
    end
  end

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
        :at => Time.now.to_i * 1000,
        :sentry => sentry_id1
      }
    end
    let(:presence2) do
      {
        :userId => user_id2,
        :userType => 4,
        :userData => 'userData2',
        :clientId => client_id2,
        :online => true,
        :at => Time.now.to_i * 1000,
        :sentry => sentry_id1
      }
    end
    let(:presence3) do
      {
        :userId => user_id1,
        :userType => 2,
        :userData => 'userData3',
        :clientId => client_id3,
        :online => true,
        :at => Time.now.to_i * 1000
      }
    end
    let(:presence4) do
      {
        :userId => user_id4,
        :userType => 4,
        :userData => 'userData4',
        :clientId => client_id4,
        :online => false,
        :at => 0
      }
    end
    let(:presence5) do
      {
        :userId => user_id5,
        :userType => 2,
        :userData => 'userData5',
        :clientId => client_id5,
        :online => true,
        :at => (Time.now.to_i - 100) * 1000
      }
    end
    let(:presence6) do
      {
        :userId => user_id6,
        :userType => 2,
        :userData => 'userData6',
        :clientId => client_id6,
        :online => true,
        :at => Time.now.to_i * 1000,
        :sentry => sentry_id2
      }
    end
    let(:presence7) do
      {
        :userId => user_id6,
        :userType => 2,
        :userData => 'userData7',
        :clientId => client_id7,
        :online => true,
        :at => Time.now.to_i * 1000,
        :sentry => sentry_id3
      }
    end
    let(:sentry1) do
      {
        :name => sentry_id1,
        :expiration => (Time.now.to_i + 100) * 1000,
        :host => "precise64",
        :port => "8000"
      }
    end
    let(:sentry2) do
      {
        :name => sentry_id2,
        :expiration => (Time.now.to_i - 100) * 1000,
        :host => "precise64",
        :port => "8000"
      }
    end

    before do
      fakeredis.hset(key, "#{user_id1}.#{client_id1}", presence1.to_json)
      fakeredis.hset(key, "#{user_id2}.#{client_id2}", presence2.to_json)
      fakeredis.hset(key, "#{user_id1}.#{client_id3}", presence3.to_json)
      fakeredis.hset(key, "#{user_id4}.#{client_id4}", presence4.to_json) # offline

      fakeredis.hset(key, "#{user_id6}.#{client_id6}", presence6.to_json) # sentry expired
      fakeredis.hset(key, "#{user_id6}.#{client_id7}", presence7.to_json) # sentry offline

      fakeredis.hset(redis_sentries_key, sentry_id1, sentry1.to_json)
      fakeredis.hset(redis_sentries_key, sentry_id2, sentry2.to_json)
    end

    after do
      fakeredis.del(key)
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
      assert_equal result.to_json, client.presence(scope).get.to_json
    end

    it 'does not crash if the key does not exist' do
      assert_equal client.presence('inexistant').get, {}
    end
  end

  describe "status" do
    let(:key) { "status:/#{subdomain}/#{scope}" }
    let(:status1) { 'status1' }
    let(:status2) { { 'hello' => 'world' } }

    before do
      fakeredis.hset(key, user_id1, status1.to_json)
      fakeredis.hset(key, user_id2, status2.to_json)
    end

    after do
      fakeredis.del(key)
    end

    it 'can retrieve a status' do
      assert_equal client.status(scope).get(user_id1), status1
      assert_equal client.status(scope).get(user_id2), status2
      assert_equal client.status(scope).get(user_id4), nil
      assert_equal client.status('inexistant').get('non-key'), nil
    end

    it 'can set a status' do
      fakeredis.expects(:publish).with(key, { :to => key, :op => 'set', :key => user_id4, :value => { :state => 'updated'} }.to_json)
      fakeredis.expects(:expire).with(key, 12*60*60)
      client.status(scope).set(user_id4, { :state => 'updated' })
      assert_equal fakeredis.hget(key, user_id4), { :state => 'updated' }.to_json
    end
  end

  describe 'message' do
    let(:key) { "message:/#{subdomain}/#{scope}" }
    let(:message1) { 'message 1' }
    let(:message2) { { 'hello' => 'world' } }

    it 'can retrieve messages' do
      # have to do this way, stupid fakeredis does not support -ve indices for zrange.
      fakeredis.expects(:zrange).with(key, -100, -1, :with_scores => true).returns(
        [[message1.to_json, 123], [ message2.to_json, 124]]
      )
      assert_equal client.message(scope).get, [[message1, 123], [message2, 124]]
    end
    it 'does not crash on inexistant keys' do
      assert_equal client.message('inexistant').get, []
    end
  end
end
