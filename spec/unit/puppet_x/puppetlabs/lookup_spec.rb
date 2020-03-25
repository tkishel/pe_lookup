require 'spec_helper'

require 'puppet_x/puppetlabs/lookup.rb'

describe PuppetX::Puppetlabs::Lookup do
  subject(:lookup) { described_class.new(param: 'puppet_enterprise::profile::console::delayed_job_workers') }

  # This is a stub.
  context 'with its supporting methods' do
    it 'output a line' do
      expect(lookup::output_line).to eq(0)
    end
  end
end
