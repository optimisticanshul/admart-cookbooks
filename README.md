# admart-cookbooks
Must format the NameNode, start the NameNode, and start (at least) one DataNode before you can create a directory in HDFS. Since it is very likely that the NameNode and DataNode reside on different machines, orchestration is required and automatically performing these actions could be dangerous. Recipes/resources need to be executed as follows:

recipe[hadoop::hadoop_hdfs_namenode] on NameNode machine

recipe[hadoop::hadoop_hdfs_datanode] on all DataNode machines

execute[hdfs-namenode-format] with action :run from recipe[hadoop::hadoop_hdfs_namenode] on NameNode machine
hadoop_wrapper::hadoop_hdfs_namenode_init

service[hadoop-hdfs-namenode] with action :start from recipe[hadoop::hadoop_hdfs_namenode] on NameNode machine
hadoop_wrapper::namenode_service

service[hadoop-hdfs-datanode] with action :start from recipe[hadoop::hadoop_hdfs_datanode] on all DataNode machines
hadoop_wrapper::datanode_service

At this point, you will have a functional HDFS cluster and can perform hdfs commands.

http://www.cloudera.com/downloads/cdh/5-1-3.html


{
   "hadoop":{
      "hdfs_site":{
         "dfs.datanode.data.dir":"file:///app/data",
         "dfs.namenode.name.dir":"file:///app/dfs/name"
      },
      "core_site":{
         "fs.defaultFS":"hdfs://namenode.localdomain"
      },
      "yarn_site":{
         "yarn.resourcemanager.hostname":"namenode.localdomain",
         "yarn.nodemanager.local-dirs":"/app/hadoop-yarn/cache/${user.name}/nm-local-dir",
         "yarn.nodemanager.log-dirs":"/var/log/hadoop-yarn/containers",
         "yarn.log-aggregation-enable":"true",
         "yarn.nodemanager.remote-app-log-dir":"hdfs://namenode.localdomain:8020/var/log/hadoop-yarn/apps"
      },
      "mapred_site":{
         "mapreduce.framework.name":"yarn"
      }
   }
}
