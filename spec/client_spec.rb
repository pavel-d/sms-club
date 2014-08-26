require 'spec_helper'
require 'webmock/rspec'
require 'uri'

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

      expect(a_request(:post, 'https://gate.smsclub.mobi/hfw_smpp_addon/xmlsendsmspost.php')
          .with { |req| URI.decode(req.body) =~ /\+380666128206/ })
          .to have_been_made
    end

    it 'should send messages to multiple recipients' do
      result = client.send 'test', to: ['+380664018206', '+380666018203', '+380666018202']

      expect(result).to be_an Array
      expect(result.length).to eq 3

      expect(a_request(:post, 'https://gate.smsclub.mobi/hfw_smpp_addon/xmlsendsmspost.php')
          .with { |req| URI.decode(req.body) =~ /\+380664018206;\+380666018203;\+380666018202/ })
          .to have_been_made
    end
  end

  describe '#status_for' do
    before do
      stub_request(:post, 'https://gate.smsclub.mobi/hfw_smpp_addon/xmlgetsmsstatepost.php')
         .to_return(status: 200, body: File.open('./spec/fixtures/xmlgetsmsstatepost.xml'), headers: {})
    end
    it 'should return hash of message statuses' do
      result = client.status_for 'ID_1'
      expect(result).to eq :state
    end
  end
end
