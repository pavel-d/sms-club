require 'spec_helper'
require 'webmock/rspec'
require 'uri'
require 'sms-club/async'

describe SmsClub::Client do

  let(:client) { SmsClub::Client.new '380993123123', 'password', from: 'KupiChehol' }

  describe '#send' do
    before do
      stub_request(:post, 'https://gate.smsclub.mobi/hfw_smpp_addon/xmlsendsmspost.php')
         .to_return(status: 200, body: File.open('./spec/fixtures/xmlsendsmspost.xml'), headers: {})
    end

    it 'should send message one recipient' do
      result = client.send_one 'test', to: '+380666128206'

      expect(result).to be_a String
      expect(result).to eq 'ID_1'
    end

    it 'should send messages to multiple recipients' do
      result = client.send 'test', to: ['+380664018206', '+380666018203', '+380666018202']

      expect(result).to be_an Array
      expect(result.length).to eq 3
    end

    describe 'an POST HTTP request' do
      it 'should include phone number' do
        client.send_one 'test', to: '+380666128206'

        expect(a_request(:post, 'https://gate.smsclub.mobi/hfw_smpp_addon/xmlsendsmspost.php')
          .with { |req| URI.decode(req.body) =~ /\+380666128206/ })
          .to have_been_made
      end

      it 'should include multiple phone numbers' do
        client.send 'test', to: ['+380664018206', '+380666018203', '+380666018202']

        expect(a_request(:post, 'https://gate.smsclub.mobi/hfw_smpp_addon/xmlsendsmspost.php')
            .with { |req| URI.decode(req.body) =~ /\+380664018206;\+380666018203;\+380666018202/ })
            .to have_been_made
      end
    end

    it 'should throw error if send failed' do
      stub_request(:post, 'https://gate.smsclub.mobi/hfw_smpp_addon/xmlsendsmspost.php')
         .to_return(status: 200, body: File.open('./spec/fixtures/xmlsendsmspost.failed.xml'), headers: {})
      expect { client.send 'test', to: ['+380664018206', '+380666018203', '+380666018202'] }.to raise_error
    end

    it 'should transliterate message when tranliterate: true' do
      client.send_one 'привет', to: '+380666128206', transliterate: true
      expect(a_request(:post, 'https://gate.smsclub.mobi/hfw_smpp_addon/xmlsendsmspost.php')
            .with { |req| req.body =~ /privet/ }).to have_been_made
    end
  end

  describe '#status_for' do
    before do
      stub_request(:post, 'https://gate.smsclub.mobi/hfw_smpp_addon/xmlgetsmsstatepost.php')
         .to_return(status: 200, body: File.open('./spec/fixtures/xmlgetsmsstatepost.xml'), headers: {})
    end
    it 'should return status symbol' do
      result = client.status_for 'ID_1'
      expect(result).to eq :delivrd
    end

    it 'should return hash of message statuses' do
      result = client.statuses_for ['ID_1', 'ID_2']
      expect(result).to eq [{ 'ID_1' => :delivrd }, { 'ID_2' => :delivrd }]
    end
  end
end

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
  end
end