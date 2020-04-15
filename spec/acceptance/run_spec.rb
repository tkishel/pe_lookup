require 'spec_helper_acceptance'

# BEAKER_provision=yes PUPPET_INSTALL_TYPE=pe bundle exec rake beaker:default

describe 'run' do
  context 'puppet pe lookup' do
    it 'and output results' do
      on(master, puppet('pe', 'lookup', 'puppet_enterprise::profile::console::delayed_job_workers'), acceptable_exit_codes: 0) do |result|
        expect(result.stdout).to match(%r{Key: puppet_enterprise::profile::console::delayed_job_workers})
      end
    end
  end
end
