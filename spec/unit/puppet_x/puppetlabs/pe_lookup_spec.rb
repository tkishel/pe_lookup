require 'spec_helper'

require 'puppet_x/puppetlabs/pelookup.rb'

describe PuppetX::Puppetlabs::PELookup do
  options = { node: 'agent.example.com', pe_environment: 'production' }
  subject(:pelookup) { described_class.new(options) }

  context 'with its supporting methods' do
    it 'can output a line' do
      expect(pelookup::output_line).to eq(nil)
    end
  end
end
