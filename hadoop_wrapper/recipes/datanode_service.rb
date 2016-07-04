pkg = 'hadoop-hdfs-datanode'
service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action [:start]
end

pkg = 'hadoop-yarn-nodemanager'
service pkg do
  status_command "service #{pkg} status"
  supports [restart: true, reload: false, status: true]
  action [:start]
end
