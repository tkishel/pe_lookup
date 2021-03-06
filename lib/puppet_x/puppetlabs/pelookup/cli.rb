#!/opt/puppetlabs/puppet/bin/ruby

require 'optparse'
require 'puppet'
require 'json'
require 'yaml'

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

require 'puppet/util/pe_conf'
require 'puppet/util/pe_conf/recover'

Puppet.initialize_settings

require_relative '../pelookup'

options = {}
parser = OptionParser.new do |opts|
  opts.banner = 'Usage: pelookup.rb <KEY> [--node CERTNAME] [--pe_environment ENVIRONMENT]'
  opts.separator ''
  opts.separator 'Summary: Output a key defined in Hiera and/or the Classifier'
  opts.separator ''
  opts.separator 'Options:'
  opts.separator ''

  options[:node] = Puppet[:certname]
  opts.on('--node CERTNAME', 'The node to lookup. Defaults to current node') do |node|
    options[:node] = node
  end

  options[:pe_environment] = 'production'
  opts.on('--pe_environment ENVIRONMENT', "The environment of the node to lookup. Defaults to 'production'") do |pe_environment|
    options[:pe_environment] = pe_environment
  end

  opts.on('-h', '--help') do
    puts opts
    puts
    exit 0
  end
end
parser.parse!

setting = ARGV.empty? ? nil : ARGV[0]

Puppet::Util::Log.newdestination :console
Puppet.debug = options[:debug]
Puppet.debug("Command Argument: #{setting}")
Puppet.debug("Command Options: #{options}")
PELookup = PuppetX::Puppetlabs::PELookup.new(options)
PELookup.lookup(setting)
