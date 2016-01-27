# RSS::Connector

Talks to RSS.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rss-connector'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rss-connector

## Usage

```ruby
RSS.configure do |config|
  config.base_uri = 'rss_url'
  config.secret = 'secret'
end

RSS.load!
```


TODO: Write usage instructions here

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shore-gmbh/rss-connector.
