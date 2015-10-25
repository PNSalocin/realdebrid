[![Build Status](https://travis-ci.org/PNSalocin/realdebrid.svg?branch=master)](https://travis-ci.org/PNSalocin/realdebrid)
[![Coverage Status](https://coveralls.io/repos/PNSalocin/realdebrid/badge.svg?branch=master&service=github)](https://coveralls.io/github/PNSalocin/realdebrid?branch=master)
# Realdebrid

Easy dialog with realdebrid.
Unrestrict links, get account informations or the list of available hosters with ease.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'realdebrid'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install realdebrid

## Usage

### Unrestrict a link

```ruby
rd_api = RealDebrid::Api.new username: 'myusername', password: 'mypassword'
unrestricted_resource = rd_api.unrestrict 'http://hoster.net/file/filehash/filename.iso.html'
```

### Get account info

```ruby
rd_api = RealDebrid::Api.new username: 'myusername', password: 'mypassword'
account_info = rd_api.account_info
```

### Get available hosters

```ruby
rd_api = RealDebrid::Api.new username: 'myusername', password: 'mypassword'
hosters = rd_api.hosters
```

## Tests

Please fill the following constants, or set the corresponding ENV variables in `realdebrid_spec.rb`:

```ruby
  VALID_USERNAME = ENV['REALDEBRID_VALID_USERNAME'] || ''
  VALID_PASSWORD = ENV['REALDEBRID_VALID_PASSWORD'] || ''
  VALID_LINK     = ENV['REALDEBRID_VALID_LINK'] || ''
```

to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PNSalocin/realdebrid.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).