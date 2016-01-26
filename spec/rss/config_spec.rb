require 'spec_helper'

describe 'RSS Library Configuration' do
  before do
    RSS.configure do |config|
      config.base_uri = 'foo'
      config.secret = 'bar'
    end
  end

  it 'stores base_uri' do
    expect(RSS.configuration.base_uri).to eq('foo')
  end

  it 'stores secret' do
    expect(RSS.configuration.secret).to eq('bar')
  end

  describe '.load!' do
    it 'loads the Connector class' do
      expect { RSS::Connector.new }.to raise_error
      RSS.load!
      expect { RSS::Connector.new('a', 'b') }.not_to raise_error
    end
  end
end
