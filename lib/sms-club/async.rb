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
      super
    end

    def self.queue
      'sms_club'
    end

    def send_async(message, options = {})
      begin
        Resque.enqueue(self.class, @init_args, message, options)
      rescue Redis::CannotConnectError => e
        warn e
        warn 'Can not connect to redis server. Falling back to synchronous mode.'
        send_many message, options
      end
    end

    def self.perform(init_args, message, msg_options)
      # Ugliness level 99. Needed to pass args to constructor
      # when Resque instantiate AsyncClient
      user_name, password, options = init_args

      # Resque serializes params to json, so symbols are
      # converted to strings, which is not what we want
      puts new(user_name, password, options.symbolize_keys!)
              .send_many(message, msg_options.symbolize_keys!)
    end
  end
end
