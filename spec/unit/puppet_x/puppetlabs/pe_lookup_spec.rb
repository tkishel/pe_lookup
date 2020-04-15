require 'spec_helper'

require 'puppet_x/puppetlabs/pelookup.rb'

describe PuppetX::Puppetlabs::PELookup do
  subject(:pelookup) { described_class.new }

  # This is a stub.
  context 'with its supporting methods' do
    it 'output a line' do
      expect(pelookup::output_line).to eq(0)
    end
  end
end
