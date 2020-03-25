require 'spec_helper'

require 'puppet_x/puppetlabs/lookup.rb'

def suppress_standard_output
  allow(STDOUT).to receive(:puts)
end

describe PuppetX::Puppetlabs::Lookup do
  subject(:lookup) { described_class.new(:param => 'puppet_enterprise::profile::console::delayed_job_workers') }

  before(:each) do
    suppress_standard_output
  end
end
