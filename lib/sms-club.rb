%w(
  version
  client
  errors
).each { |file| require File.join(File.dirname(__FILE__), 'sms-club', file) }
