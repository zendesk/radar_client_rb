require_relative '../../minitest_helper'
require_relative '../../../lib/radar_client_rb/message'

describe Radar::Message do
  def assert_exception(excep, message_regexp = nil, &block)
    exception = assert_raises(excep, &block)

    if message_regexp
      assert_match message_regexp, exception.message
    end
  end

  describe '.new' do

    it 'raises ArgumentError on on invalid constructor arguments' do
      attrs = { to: 'to', op: 'op' }

      assert_exception(ArgumentError) { Radar::Message.new() }

      assert_exception(ArgumentError, /^op/) { Radar::Message.new(attrs.merge(op: nil)) }      
      assert_exception(ArgumentError, /^op/) { Radar::Message.new(attrs.merge(op: '')) }    
    end

    it 'instantiates a new message object' do
      message = Radar::Message.new(to: 'status:/foo/bar', op: 'get', key: 'x')
      assert_instance_of Radar::Message, message
    end

  end

  describe '.from_json' do
    it 'parses json string and instantiates Radar::Message' do
      json = '{"to":"foo","op":"get","key":"k","value":"v"}'
      message = Radar::Message.from_json(json)
      assert_instance_of Radar::Message, message
      assert_equal message.to, 'foo'
      assert_equal message.op, 'get'
      assert_equal message.key, 'k'
      assert_equal message.value, 'v'
    end
  end

  describe '.merge' do
    it 'creates a new message from an existing message, overriding some properties' do
      msg = Radar::Message.new(op: 'foo', to: 'bar', key: 'baz', value: 'qux')
      # msg2 = Radar::Message.new(op: 'foo', to: 'bar', key: 'baz', value: 'qux')
      msg2 = msg.merge(value: 'zot')
      assert !msg.equal?(msg2)
      assert_equal 'foo', msg2.op
      assert_equal 'bar', msg2.to
      assert_equal 'baz', msg2.key
      assert_equal 'zot', msg2.value
    end
  end

  describe '#to_json' do
    it 'serializes message fields' do
      message = Radar::Message.new(op: 'o', to: 't', key: 'k', value: 'v')
      assert_equal '{"op":"o","to":"t","key":"k","value":"v"}', message.to_json
    end
    
    it 'omits nil values' do
      message = Radar::Message.new(op: 'o', to: 't')
      assert_equal '{"op":"o","to":"t"}', message.to_json
    end
  end

  describe 'structural equality' do
    let(:msg1) { Radar::Message.new(op: 'a', to: 'b', key: 'k', value:'v')}
    let(:msg2) { Radar::Message.new(op: 'a', to: 'b', key: 'k', value:'v')}
    
    it '==' do
      assert msg1 == msg2
    end

    it '===' do
      assert msg1 === msg2
    end
    
    it 'eql?' do
      assert msg1.eql? msg2
    end
    
    it 'can be used in a hashmap' do
      x = {}
      x[msg1] = 'x'
      assert x.has_key?(msg1)
      assert x.has_key?(msg2)
    end
  end

end
