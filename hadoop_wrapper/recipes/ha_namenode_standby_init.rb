#
# Cookbook Name:: hadoop_wrapper
# Recipe:: ha_namenode_standby_init
#
# Copyright © 2013-2016 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'hadoop_wrapper::default'
include_recipe 'hadoop::hadoop_hdfs_namenode'

ruby_block 'initaction-hdfs-namenode-bootstrap-standby' do
  block do
    resources(execute: 'hdfs-namenode-bootstrap-standby').run_action(:run)
  end
end
