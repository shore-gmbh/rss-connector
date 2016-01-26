# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rss/version'

Gem::Specification.new do |spec|
  spec.name          = 'rss-connector'
  spec.version       = RSS::VERSION
  spec.authors       = ['Dylan Johnston']
  spec.email         = ['dylan.johnston@shore.com']

  spec.summary       = 'Connector for RSS'
  spec.description   = 'Easy access to the Recurrence Service Store and its data.'
  spec.homepage      = 'shore.com'
  spec.license       = 'Proprietary'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: Set to a private GEM host\''
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty', '~> 0.10.2'
  spec.add_dependency 'activesupport', '> 3.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov', '>= 0.10'
  spec.add_development_dependency 'rubocop', '>= 0.35.1'
  spec.add_development_dependency 'overcommit', '>= 0.29.1'
end
