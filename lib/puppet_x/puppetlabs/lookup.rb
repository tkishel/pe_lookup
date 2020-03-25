#!/opt/puppetlabs/puppet/bin/ruby

# Output a class parameter defined in Hiera and/or the Classifier.

module PuppetX
  module Puppetlabs
    # Output a class parameter defined in Hiera and/or the Classifier.
    class Lookup
      attr_reader :environment

      # Initialize command options, class variables, and objects.
      def initialize(options)
        unless options[:param]
          output_error_and_exit('The --param option is required')
        end

        unless options[:node]
          output_error_and_exit('The --node option is required')
        end

        unless options[:pe_environment]
          output_error_and_exit('The --pe_environment option is required')
        end
        @environment = options[:pe_environment]
      end

      # Output the specified class parameter defined in Hiera and/or the Classifier.

      def output_current_setting(certname, setting_name)
        current_settings = hiera_classifier_settings(certname, [setting_name])
        output_error_and_exit('Unable to query Hiera or the Classifier') if current_settings.nil?

        current_settings['hiera'] = current_settings['hiera'].select { |k, _v| k == setting_name }
        current_settings['classifier'] = current_settings['classifier'].select { |k, _v| k == setting_name }
        output ("Node: %{certname}") % { certname: certname }
        output ("Parameter: %{setting_name}") % { setting_name: setting_name }
        output_line

        found_in_hiera = current_settings['hiera'].key?(setting_name)
        if found_in_hiera
          output ('Parameter found in Hiera:')
          output_line
          output_data (current_settings['hiera'].to_yaml)
        else
          output ('Parameter not found in Hiera')
        end
        output_line

        found_in_classifier = current_settings['classifier'].key?(setting_name)
        if found_in_classifier
          output ('Parameter found in the Classifier:')
          output_line
          output_data(JSON.pretty_generate(current_settings['classifier']))
        else
          output ('Parameter not found in the Classifier')
        end
        output_line

        if found_in_hiera && found_in_classifier
          output ('Classifier settings take precedence over Hiera settings.')
          output_line
        end
      end

      #
      # Interface to Puppet::Util::Pe_conf::Recover.
      #

      def hiera_classifier_settings(certname, setting_names)
        overrides_hiera, overrides_classifier = hiera_classifier_overrides(certname, setting_names)
        Puppet.debug("Settings: #{setting_names}")
        Puppet.debug("Settings from Hiera for: #{certname}: #{overrides_hiera}")
        Puppet.debug("Settings from Classifier for: #{certname}: #{overrides_classifier}")
        return { 'hiera' => overrides_hiera, 'classifier' => overrides_classifier }
      rescue Puppet::Error
        return nil
      end

      # Extract the beating heart of a puppet compiler for lookup purposes.

      def hiera_classifier_overrides(certname, settings)
        if recover_with_instance_method?
          recover = Puppet::Util::Pe_conf::Recover.new
          recover_node_facts = recover.facts_for_node(certname, @environment)
          node_terminus = recover.get_node_terminus
          overrides_hiera = recover.find_hiera_overrides(certname, settings, recover_node_facts, @environment, node_terminus)
          overrides_classifier = recover.classifier_overrides_for_node(certname, recover_node_facts, recover_node_facts['::trusted'])
        else
          recover_node_facts = Puppet::Util::Pe_conf::Recover.facts_for_node(certname, @environment)
          if recover_with_node_terminus_method?
            node_terminus = Puppet::Util::Pe_conf::Recover.get_node_terminus
            overrides_hiera = Puppet::Util::Pe_conf::Recover.find_hiera_overrides(certname, settings, recover_node_facts, @environment, node_terminus)
          else
            overrides_hiera = Puppet::Util::Pe_conf::Recover.find_hiera_overrides(settings, recover_node_facts, @environment)
          end
          overrides_classifier = Puppet::Util::Pe_conf::Recover.classifier_overrides_for_node(certname, recover_node_facts, recover_node_facts['::trusted'])
        end
        [overrides_hiera, overrides_classifier]
      end

      # PE-24106 changes Recover to a class with instance methods.

      def recover_with_instance_method?
        defined?(Puppet::Util::Pe_conf::Recover.facts_for_node) != 'method'
      end

      # In some versions, Puppet::Util::Pe_conf::Recover does not implement get_node_terminus() and implements find_hiera_overrides(params, facts, environment)

      def recover_with_node_terminus_method?
        defined?(Puppet::Util::Pe_conf::Recover.get_node_terminus) == 'method'
      end

      #
      # Output
      #

      def output(info)
        puts "# #{info}"
      end

      def output_line
        puts "\n"
      end

      # Output highlighted output, from 'puppet/util/colors'.

      def output_data(info)
        puts "\e[0;32m#{info}\e[0m"
      end

      # Output an error and exit.

      def output_error_and_exit(message)
        Puppet.err(message)
        Puppet.err("Rerun this command with '--debug' or '--help' for more information")
        exit 1
      end
    end
  end
end

# The following code allows this class to be executed as a standalone script,
# or as 'puppet pe lookup'

if File.expand_path(__FILE__) == File.expand_path($PROGRAM_NAME)
  require_relative 'lookup/cli'
else
  require 'puppet/util/pe_conf'
  require 'puppet/util/pe_conf/recover'
  require 'puppet/util/puppetdb'
end
