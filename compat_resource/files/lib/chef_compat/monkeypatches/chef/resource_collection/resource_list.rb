#
# Author:: Tyler Ball (<tball@chef.io>)
# Copyright:: Copyright 2014-2016, Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/resource_collection/resource_list'
require 'chef/exceptions'

module ChefCompat
  module Monkeypatches
    module Chef
      module ResourceCollection
        module ResourceList
          module DeleteResource
            # Copied verbatim from Chef 12.10.4
            def delete(key)
              raise ArgumentError, 'Must pass a Chef::Resource or String to delete' unless key.is_a?(String) || key.is_a?(Chef::Resource)
              key = key.to_s
              ret = @resources.reject! { |r| r.to_s == key }
              if ret.nil?
                raise ::Chef::Exceptions::ResourceNotFound, "Cannot find a resource matching #{key} (did you define it first?)"
              end
              ret
            end
          end
        end
      end
    end
  end
end

class Chef::ResourceCollection::ResourceList
  unless method_defined?(:delete)
    prepend ChefCompat::Monkeypatches::Chef::ResourceCollection::ResourceList::DeleteResource
  end
end
