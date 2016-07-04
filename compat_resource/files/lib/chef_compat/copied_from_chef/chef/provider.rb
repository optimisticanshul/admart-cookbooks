begin
  require 'chef/provider'
rescue LoadError; end

require 'chef_compat/copied_from_chef'
class Chef
  module ::ChefCompat
    module CopiedFromChef
      require 'chef_compat/copied_from_chef/chef/dsl/core'
      class Chef < (defined?(::Chef) ? ::Chef : Object)
        class Provider < (defined?(::Chef::Provider) ? ::Chef::Provider : Object)
          include Chef::DSL::Core
          attr_accessor :action
          def initialize(new_resource, run_context)
            super if defined?(::Chef::Provider)
            @new_resource = new_resource
            @action = action
            @current_resource = nil
            @run_context = run_context
            @converge_actions = nil

            @recipe_name = nil
            @cookbook_name = nil
            self.class.include_resource_dsl_module(new_resource)
          end

          def converge_if_changed(*properties, &converge_block)
            unless converge_block
              raise ArgumentError, 'converge_if_changed must be passed a block!'
            end

            properties = new_resource.class.state_properties.map(&:name) if properties.empty?
            properties = properties.map(&:to_sym)
            if current_resource
              # Collect the list of modified properties
              specified_properties = properties.select { |property| new_resource.property_is_set?(property) }
              modified = specified_properties.select { |p| new_resource.send(p) != current_resource.send(p) }
              if modified.empty?
                properties_str = if sensitive
                                   specified_properties.join(', ')
                                 else
                                   specified_properties.map { |p| "#{p}=#{new_resource.send(p).inspect}" }.join(', ')
                                 end
                Chef::Log.debug("Skipping update of #{new_resource}: has not changed any of the specified properties #{properties_str}.")
                return false
              end

              # Print the pretty green text and run the block
              property_size = modified.map(&:size).max
              modified.map! do |p|
                properties_str = if sensitive
                                   '(suppressed sensitive property)'
                                 else
                                   "#{new_resource.send(p).inspect} (was #{current_resource.send(p).inspect})"
                                 end
                "  set #{p.to_s.ljust(property_size)} to #{properties_str}"
              end
              converge_by(["update #{current_resource.identity}"] + modified, &converge_block)

            else
              # The resource doesn't exist. Mark that we are *creating* this, and
              # write down any properties we are setting.
              property_size = properties.map(&:size).max
              created = properties.map do |property|
                default = ' (default value)' unless new_resource.property_is_set?(property)
                properties_str = if sensitive
                                   '(suppressed sensitive property)'
                                 else
                                   new_resource.send(property).inspect
                                 end
                "  set #{property.to_s.ljust(property_size)} to #{properties_str}#{default}"
              end

              converge_by(["create #{new_resource.identity}"] + created, &converge_block)
            end
            true
          end

          def self.include_resource_dsl(include_resource_dsl)
            @include_resource_dsl = include_resource_dsl
          end

          def self.include_resource_dsl_module(resource)
            if @include_resource_dsl && !defined?(@included_resource_dsl_module)
              provider_class = self
              @included_resource_dsl_module = Module.new do
                extend Forwardable
                define_singleton_method(:to_s) { "forwarder module for #{provider_class}" }
                define_singleton_method(:inspect) { to_s }
                # Add a delegator for each explicit property that will get the *current* value
                # of the property by default instead of the *actual* value.
                resource.class.properties.each do |name, _property|
                  class_eval(<<-EOM, __FILE__, __LINE__)
              def #{name}(*args, &block)
                # If no arguments were passed, we process "get" by defaulting
                # the value to current_resource, not new_resource. This helps
                # avoid issues where resources accidentally overwrite perfectly
                # valid stuff with default values.
                if args.empty? && !block
                  if !new_resource.property_is_set?(__method__) && current_resource
                    return current_resource.public_send(__method__)
                  end
                end
                new_resource.public_send(__method__, *args, &block)
              end
            EOM
                end
                dsl_methods =
                  resource.class.public_instance_methods +
                  resource.class.protected_instance_methods -
                  provider_class.instance_methods -
                  resource.class.properties.keys
                def_delegators(:new_resource, *dsl_methods)
              end
              include @included_resource_dsl_module
            end
          end

          def self.use_inline_resources
            extend InlineResources::ClassMethods
            include InlineResources
          end
          module InlineResources
            CopiedFromChef.extend_chef_module(::Chef::Provider::InlineResources, self) if defined?(::Chef::Provider::InlineResources)
            def compile_and_converge_action(&block)
              old_run_context = run_context
              @run_context = run_context.create_child
              return_value = instance_eval(&block)
              Chef::Runner.new(run_context).converge
              return_value
            ensure
              if run_context.resource_collection.any?(&:updated?)
                new_resource.updated_by_last_action(true)
              end
              @run_context = old_run_context
            end
            module ClassMethods
              CopiedFromChef.extend_chef_module(::Chef::Provider::InlineResources::ClassMethods, self) if defined?(::Chef::Provider::InlineResources::ClassMethods)
              def action(name, &block)
                # We need the block directly in a method so that `super` works
                define_method("compile_action_#{name}", &block)
                # We try hard to use `def` because define_method doesn't show the method name in the stack.
                begin
                  class_eval <<-EOM
              def action_#{name}
                compile_and_converge_action { compile_action_#{name} }
              end
            EOM
                rescue SyntaxError
                  define_method("action_#{name}") { send("compile_action_#{name}") }
                end
              end
            end
          end

          protected
        end
      end
    end
  end
end
