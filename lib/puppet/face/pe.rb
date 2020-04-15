require 'puppet/indirector/face'

# Load puppet enterprise modules.
# Note that the location of enterprise modules varies from version to version.

enterprise_modules = ['pe_infrastructure', 'pe_install', 'pe_manager']
env_mod = '/opt/puppetlabs/server/data/environments/enterprise/modules'
ent_mod = '/opt/puppetlabs/server/data/enterprise/modules'
enterprise_module_paths = [env_mod, ent_mod]
enterprise_module_paths.each do |enterprise_module_path|
  next unless File.directory?(enterprise_module_path)
  enterprise_modules.each do |enterprise_module|
    enterprise_module_lib = "#{enterprise_module_path}/#{enterprise_module}/lib"
    next if $LOAD_PATH.include?(enterprise_module_lib)
    Puppet.debug("Adding #{enterprise_module} to LOAD_PATH: #{enterprise_module_lib}")
    $LOAD_PATH.unshift(enterprise_module_lib)
  end
end

require_relative '../../puppet_x/puppetlabs/pelookup'

Puppet::Face.define(:pe, '1.0.0') do
  summary _('Puppet Enterprise Support Tooling')
  description <<-'DESC'
    Puppet Enterprise Support Tooling
  DESC

  action(:lookup) do
    summary 'Output a key defined in Hiera and/or the Classifier'
    arguments '<KEY>'
    description <<-'DESC'
      Output a key defined in Hiera and/or the Classifier.
    DESC

    option '--node CERTNAME' do
      summary 'The node to lookup. Defaults to current node'
      default_to { Puppet[:certname] }
    end
    option '--pe_environment ENVIRONMENT' do
      summary "The environment of the node to lookup. Defaults to 'production'"
      default_to { 'production' }
    end

    when_invoked do |*args|
      options = args.pop
      setting = args.empty? ? nil : args[0]
      Puppet.debug("Command Argument: #{setting}")
      Puppet.debug("Command Options: #{options}")
      PELookup = PuppetX::Puppetlabs::PELookup.new(options)
      PELookup.lookup(setting)
      return
    end
  end
end
