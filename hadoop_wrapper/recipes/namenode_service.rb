pkg = 'hadoop-hdfs-namenode'
service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action [:restart]
end

pkg = 'hadoop-yarn-resourcemanager'
service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action [:restart]
end

pkg = 'hadoop-mapreduce-historyserver'
service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action [:restart]
end

pkg = 'hadoop-hdfs-secondarynamenode'
service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action [:restart]
end

include_recipe 'hadoop_wrapper::datanode_service'
