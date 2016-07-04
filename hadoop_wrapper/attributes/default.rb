# variables
jmx_base = '-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false'

# Java
default['java']['install_flavor'] = 'oracle'
default['java']['jdk_version'] = 7
default['java']['oracle']['accept_oracle_download_terms'] = true

# Hadoop
# core-site.xml
default['hadoop']['core_site']['hadoop.tmp.dir'] = '/hadoop'
# hdfs-site.xml
default['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads'] = '4096'
# mapred-site.xml
default['hadoop']['mapred_site']['mapreduce.framework.name'] = 'yarn'
# yarn-site.xml
default['hadoop']['yarn_site']['yarn.log-aggregation-enable'] = 'true'
default['hadoop']['yarn_site']['yarn.scheduler.minimum-allocation-mb'] = '512'
default['hadoop']['yarn_site']['yarn.nodemanager.resourcemanager.connect.wait.secs'] = '-1'
default['hadoop']['yarn_site']['yarn.nodemanager.vmem-check-enabled'] = 'false'
default['hadoop']['yarn_site']['yarn.nodemanager.vmem-pmem-ratio'] = '5.1'
default['hadoop']['yarn_site']['yarn.nodemanager.delete.debug-delay-sec'] = '86400'

# Memory for YARN
unless node['hadoop']['yarn_site'].key?('yarn.nodemanager.resource.memory-mb')
  mem = (node['memory']['total'].to_i / 1000)
  pct = if node['hadoop'].key?('yarn') && node['hadoop']['yarn'].key?('memory_percent')
          (node['hadoop']['yarn']['memory_percent'].to_f / 100)
        else
          0.50
        end
  default['hadoop']['yarn_site']['yarn.nodemanager.resource.memory-mb'] = (mem * pct).to_i
end

# hadoop-metrics.properties
default['hadoop']['hadoop_metrics']['dfs.class'] = 'org.apache.hadoop.metrics.spi.NullContextWithUpdateThread'
default['hadoop']['hadoop_metrics']['dfs.period'] = '60'
default['hadoop']['hadoop_metrics']['mapred.class'] = 'org.apache.hadoop.metrics.spi.NullContextWithUpdateThread'
default['hadoop']['hadoop_metrics']['mapred.period'] = '60'
default['hadoop']['hadoop_metrics']['rpc.class'] = 'org.apache.hadoop.metrics.spi.NullContextWithUpdateThread'
default['hadoop']['hadoop_metrics']['rpc.period'] = '60'
default['hadoop']['hadoop_metrics']['ugi.class'] = 'org.apache.hadoop.metrics.spi.NullContextWithUpdateThread'
default['hadoop']['hadoop_metrics']['ugi.period'] = '60'
# hadoop-env.sh
# Enable JMX
default['hadoop']['hadoop_env']['hadoop_jmx_base'] = jmx_base
default['hadoop']['hadoop_env']['hadoop_namenode_opts'] = '$HADOOP_JMX_BASE -Dcom.sun.management.jmxremote.port=8004'
default['hadoop']['hadoop_env']['hadoop_secondarynamenode_opts'] = '$HADOOP_JMX_BASE -Dcom.sun.management.jmxremote.port=8005'
default['hadoop']['hadoop_env']['hadoop_datanode_opts'] = '$HADOOP_JMX_BASE -Dcom.sun.management.jmxremote.port=8006'
# yarn-env.sh
default['hadoop']['yarn_env']['yarn_opts'] = jmx_base
default['hadoop']['yarn_env']['yarn_resourcemanager_opts'] = '$YARN_RESOURCEMANAGER_OPTS -Dcom.sun.management.jmxremote.port=8008'
default['hadoop']['yarn_env']['yarn_nodemanager_opts'] = '$YARN_NODEMANAGER_OPTS -Dcom.sun.management.jmxremote.port=8009'

# HBase
# hbase-site.xml configs
default['hbase']['hbase_site']['hbase.cluster.distributed'] = 'true'
default['hbase']['hbase_site']['hbase.defaults.for.version.skip'] = 'false'
default['hbase']['hbase_site']['hbase.regionserver.handler.count'] = '100'

# hbase-env.sh
# Enable JMX
default['hbase']['hbase_env']['hbase_log_dir'] = '/var/log/hbase'
default['hbase']['hbase_env']['common_gc_opts'] = '-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=1 -XX:GCLogFileSize=512M'
default['hbase']['hbase_env']['hbase_jmx_base'] = jmx_base
default['hbase']['hbase_env']['hbase_master_opts'] = '$COMMON_GC_OPTS $HBASE_MASTER_OPTS $HBASE_MASTER_HEAP $HBASE_JMX_BASE -Dcom.sun.management.jmxremote.port=10101'
default['hbase']['hbase_env']['server_gc_opts'] = '-Xloggc:$HBASE_LOG_DIR/gc-master.log'
default['hbase']['hbase_env']['hbase_regionserver_opts'] = '$COMMON_GC_OPTS -Xloggc:$HBASE_LOG_DIR/gc-regionserver.log $HBASE_REGIONSERVER_OPTS $HBASE_REGIONSERVER_HEAP $HBASE_JMX_BASE -Dcom.sun.management.jmxremote.port=10102'

# ZooKeeper
# zoo.cfg
default['zookeeper']['zoocfg']['autopurge.snapRetainCount'] = '7'
default['zookeeper']['zoocfg']['autopurge.purgeInterval'] = '24'
