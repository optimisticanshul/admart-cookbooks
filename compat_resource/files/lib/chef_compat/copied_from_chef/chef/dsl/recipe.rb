begin
  require 'chef/dsl/recipe'
rescue LoadError; end

require 'chef_compat/copied_from_chef'
class Chef
  module ::ChefCompat
    module CopiedFromChef
      require 'chef_compat/copied_from_chef/chef/dsl/core'
      require 'chef_compat/copied_from_chef/chef/mixin/lazy_module_include'
      class Chef < (defined?(::Chef) ? ::Chef : Object)
        module DSL
          CopiedFromChef.extend_chef_module(::Chef::DSL, self) if defined?(::Chef::DSL)
          module Recipe
            CopiedFromChef.extend_chef_module(::Chef::DSL::Recipe, self) if defined?(::Chef::DSL::Recipe)
            include Chef::DSL::Core
            extend Chef::Mixin::LazyModuleInclude
            module FullDSL
              CopiedFromChef.extend_chef_module(::Chef::DSL::Recipe::FullDSL, self) if defined?(::Chef::DSL::Recipe::FullDSL)
              include Chef::DSL::Recipe
              extend Chef::Mixin::LazyModuleInclude
            end
          end
        end
      end
      require 'chef_compat/copied_from_chef/chef/resource'
    end
  end
end
