require 'spec_helper'
require 'webmock/rspec'
require 'uri'
require 'sms-club/async'
require 'resque'

describe SmsClub::AsyncClient do
  let(:client) { SmsClub::AsyncClient.new '380993123123', 'password', from: 'KupiChehol' }

  describe '#send' do
    before do
      stub_request(:post, 'https://gate.smsclub.mobi/hfw_smpp_addon/xmlsendsmspost.php')
         .to_return(status: 200, body: File.open('./spec/fixtures/xmlsendsmspost.xml'), headers: {})
    end

    it 'should send sms asynchronously' do
      client.send_async 'test', to: '+380666128206'
    end
    it 'should fallback to synchronous mode' do
      Resque.redis = Redis.new(host: 'localhost', port: 9999)
      client.send_async 'test', to: '+380666128206'
      Resque.redis = Redis.new(host: 'localhost', port: 6379)
    end
  end
end
