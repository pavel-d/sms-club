require 'sms-club'
begin
  require 'resque'
rescue LoadError => e
  raise "You need to install resque to use async sms client"
end unless defined?(Resque)

module SmsClub
  class AsyncClient < Client
    attr_accessor :queue

    def initialize(*args)
      @init_args = args
      @queue = 'sms_club'
      super
    end

    def send_async(message, options = {})
      begin
        Resque.enqueue(self.class, @init_args, message, options)
      rescue Redis::CannotConnectError => e
        warn e
        warn 'Can not connect to redis server. Falling back to synchronous mode.'
      end
    end

    def self.perform(init_args, message, options)
      client = self.new(init_args).send_many(message, options)
    end
  end
end
