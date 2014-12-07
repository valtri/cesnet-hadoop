# == Class hadoop::create_dirs
#
# Create root directory layout at Hadoop Filesystem. Take care also for Kerberos ticket inicialization and destruction, when realm is specified.
#
# Requirements: HDFS needs to be formatted and namenode service running.
#
# This class is called from hadoop::service.
#
class hadoop::create_dirs {
  $realm = $hadoop::realm
  # hadoop.security.auth_to_local not used by ResourceManager state-store
  # (Hadoop 2.4.1)
  if ($realm) { $rmstore_user = 'rm' }
  else { $rmstore_user = 'yarn' }

  hadoop::kinit { 'hdfs-kinit':
    touchfile => 'hdfs-root-created',
  }
  ->
  hadoop::mkdir { '/user':
    touchfile => 'hdfs-root-created',
  }
  ->
  hadoop::mkdir { '/var/log':
    touchfile => 'hdfs-root-created',
  }
  ->
  hadoop::mkdir { '/tmp':
    mode      => '1777',
    touchfile => 'hdfs-root-created',
  }
  ->
  hadoop::mkdir { ['/tmp/hadoop-yarn/staging', '/tmp/hadoop-yarn/staging/history', '/tmp/hadoop-yarn/staging/history/done', '/tmp/hadoop-yarn/staging/history/done_intermediate']:
    mode      => '1777',
    owner     => 'mapred',
    group     => 'mapred',
    touchfile => 'hdfs-root-created',
  }
  ->
  hadoop::mkdir { ['/tmp/hadoop-yarn', '/var/log/hadoop-yarn']:
    owner     => 'yarn',
    group     => 'mapred',
    touchfile => 'hdfs-root-created',
  }
  ->
  # for resource manager state store feature
  hadoop::mkdir { '/rmstore':
    owner     => $rmstore_user,
    group     => 'hadoop',
    touchfile => 'hdfs-root-created',
  }
  ->
  hadoop::kdestroy { 'hdfs-kdestroy':
    touchfile => 'hdfs-root-created',
    touch     => true,
  }
}
