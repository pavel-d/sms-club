require 'faraday'
require 'nokogiri'
require 'translit'

module SmsClub
  # API documentation http://smsclub.mobi/en/pages/show/api#xml
  class Client
    attr_accessor :user_name, :password, :from, :transliterate

    def initialize(user_name, password, from: nil, transliterate: false)
      @user_name = user_name
      @password = password
      @from = from
      @transliterate = transliterate
    end

    def send_one(message, options = {})
      send(message, options).first
    end

    def send(message, options = {})
      fail ArgumentError, 'Recepient is not defined' unless options[:to]

      to = options[:to]
      to = to.map(&:to_s).join(';') if to.is_a? Array

      message = translit_message message if transliterate || options[:transliterate]
      msg_from = options[:from] || from

      payload = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.request_sendsms do
          xml.username { xml.cdata @user_name }
          xml.password { xml.cdata @password }
          xml.from { xml.cdata msg_from }
          xml.to { xml.cdata to }
          xml.text_ { xml.cdata message }
        end
      end

      response = connection.post '/hfw_smpp_addon/xmlsendsmspost.php', xmlrequest: payload.to_xml
      doc = Nokogiri::XML(response.body)

      raise SmsClubError, response_error(doc) if response_failed?(doc)

      doc.xpath('//mess').map(&:content)
    end

    def status_for(smscid)
      statuses_for(smscid).first[smscid]
    end

    def statuses_for(smscid)
      smscid = smscid.map(&:to_s).join(';') if smscid.is_a? Array

      payload = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.request_getstate do
          xml.username { xml.cdata @user_name }
          xml.password { xml.cdata @password }
          xml.smscid { xml.cdata smscid }
        end
      end

      response = connection.post '/hfw_smpp_addon/xmlgetsmsstatepost.php', xmlrequest: payload.to_xml

      doc = Nokogiri::XML(response.body)

      raise SmsClubError, response_error(doc) if response_failed?(doc)

      doc.xpath('//entry').map do |entry|
        { entry.xpath('smscid').text => entry.xpath('state').text.downcase.to_sym }
      end
    end

    protected

    def connection
      @connection ||= Faraday.new(url: 'https://gate.smsclub.mobi/') do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end

    def translit_message(message)
      Translit.convert message
    end

    def response_failed?(xml_doc)
      xml_doc.xpath('//status').text != 'OK'
    end

    def response_error(xml_doc)
      xml_doc.xpath('//text').text
    end
  end
end
