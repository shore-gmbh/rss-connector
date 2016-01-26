$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rss'
require 'securerandom'

Time.zone = 'Europe/Berlin'

RSS.configure do |config|
  config.base_uri = 'testhost'
  config.secret = 'secret'
end

RSS.load!
