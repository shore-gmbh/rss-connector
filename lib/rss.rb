require 'active_support/all'
require_relative 'rss/config'

module RSS #:nodoc:
  # Authentication credentials are stored in constants, make sure
  # configuration is set before requiring the connector.
  def self.load!
    if RSS.configuration.base_uri.empty?
      puts 'Missing RSS base_uri config'
      exit
    end

    require_relative 'rss/connector'
  end
end
