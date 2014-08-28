# SmsClub API Client

Client for http://smsclub.mobi/ SMS gate. Allows you to send and retrieve status of sent SMS via XML API.

## Installation

Add this line to your application's Gemfile:

    gem 'sms-club'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sms-club

## Usage

Create new client first. Constructor accepts your login, password for smsclub.mobi and optional default `from` argument

```
SmsClub::Client.new '380993123123', 'password', from: 'CoolCompany'
#=> #<SmsClub::Client:0x000000051f9320 @user_name="380993123123", @password="password", @from="CoolCompany", @transliterate=false>
```
You can also turn on transliteration option by default

```
client = SmsClub::Client.new '380993123123', 'password', transliterate: true
#=> #<SmsClub::Client:0x000000051b14d0 @user_name="380993123123", @password="password", @from=nil, @transliterate=true>
```

Sending SMS to multiple numbers at once

```
client.send 'test', to: ['+380664018206', '+380666018203', '+380666018202']
#=> ["ID_1", "ID_2", "ID_N"]

```

Send sms to one number
```
client.send_one 'test', to: '+380666128206'
#=> "ID_1"
```

Get status of SMS

```
client.status_for 'ID_1'
#=> :delivrd

client.statuses_for ['ID_1', 'ID_2']
#=> { 'ID_1' => :delivrd }, { 'ID_2' => :delivrd }
```

For more info please see original api docs http://smsclub.mobi/en/pages/show/api#xml

## Contributing

1. Fork it ( https://github.com/pavel-d/sms-club/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
