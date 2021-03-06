#
# Cookbook Name:: hadoop
# Recipe:: hadoop_hdfs_secondarynamenode
#
# Copyright © 2013-2015 Cask Data, Inc.
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

include_recipe 'hadoop::default'
include_recipe 'hadoop::_hadoop_hdfs_checkconfig'
include_recipe 'hadoop::_system_tuning'
pkg = 'hadoop-hdfs-secondarynamenode'

fs_checkpoint_dirs =
  if node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.namenode.checkpoint.dir')
    node['hadoop']['hdfs_site']['dfs.namenode.checkpoint.dir']
  elsif node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('fs.checkpoint.dir')
    node['hadoop']['hdfs_site']['fs.checkpoint.dir']
  else
    'file:///tmp/hadoop-hdfs/dfs/namesecondary'
  end

fs_checkpoint_edits_dirs =
  if node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('dfs.namenode.checkpoint.edits.dir')
    node['hadoop']['hdfs_site']['dfs.namenode.checkpoint.edits.dir']
  elsif node['hadoop'].key?('hdfs_site') && node['hadoop']['hdfs_site'].key?('fs.checkpoint.edits.dir')
    node['hadoop']['hdfs_site']['fs.checkpoint.edits.dir']
  else
    fs_checkpoint_dirs
  end

node.default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.dir'] = fs_checkpoint_dirs
node.default['hadoop']['hdfs_site']['dfs.namenode.checkpoint.edits.dir'] = fs_checkpoint_edits_dirs

snn_dirs =
  if fs_checkpoint_dirs == fs_checkpoint_edits_dirs
    [fs_checkpoint_dirs]
  else
    [fs_checkpoint_dirs, fs_checkpoint_edits_dirs]
  end

snn_dirs.each do |dirs|
  dirs.split(',').each do |dir|
    directory dir.gsub('file://', '') do
      mode '0700'
      owner 'hdfs'
      group 'hdfs'
      action :create
      recursive true
    end
  end
end

hadoop_log_dir =
  if node['hadoop'].key?('hadoop_env') && node['hadoop']['hadoop_env'].key?('hadoop_log_dir')
    node['hadoop']['hadoop_env']['hadoop_log_dir']
  elsif hdp22?
    '/var/log/hadoop/hdfs'
  else
    '/var/log/hadoop-hdfs'
  end

hadoop_pid_dir =
  if hdp22?
    '/var/run/hadoop/hdfs'
  else
    '/var/run/hadoop-hdfs'
  end

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'hadoop_pid_dir' => hadoop_pid_dir,
    'hadoop_log_dir' => hadoop_log_dir,
    'hadoop_namenode_user' => 'hdfs',
    'hadoop_secondarynamenode_user' => 'hdfs',
    'hadoop_datanode_user' => 'hdfs',
    'hadoop_ident_string' => 'hdfs',
    'hadoop_privileged_nfs_user' => 'hdfs',
    'hadoop_privileged_nfs_pid_dir' => hadoop_pid_dir,
    'hadoop_privileged_nfs_log_dir' => hadoop_log_dir,
    'hadoop_secure_dn_user' => 'hdfs',
    'hadoop_secure_dn_pid_dir' => hadoop_pid_dir,
    'hadoop_secure_dn_log_dir' => hadoop_log_dir
  }
end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables options: {
    'desc' => 'Hadoop HDFS SecondaryNameNode',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/hadoop/sbin/hadoop-daemon.sh",
    'args' => '--config ${CONF_DIR} start secondarynamenode',
    'confdir' => '${HADOOP_CONF_DIR}',
    'user' => 'hdfs',
    'home' => "#{hadoop_lib_dir}/hadoop",
    'pidfile' => "${HADOOP_PID_DIR}/#{pkg}.pid",
    'logfile' => "${HADOOP_LOG_DIR}/#{pkg}.log"
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action :nothing
end
