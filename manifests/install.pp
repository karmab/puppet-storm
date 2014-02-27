class storm::install inherits storm {

  group { $group:
    ensure => $group_ensure,
    gid    => $gid,
  }

  user { $user:
    ensure     => $user_ensure,
    home       => $user_home,
    shell      => $shell,
    uid        => $uid,
    comment    => $user_description,
    gid        => $group,
    managehome => $user_managehome,
    require    => Group[$group],
  }

  package { 'storm':
    ensure  => $package_ensure,
    name    => $package_name,
  }

  file { $local_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0750',
  }

  # If $log_dir does not point to the default "storm.home"/logs/ directory, we create a symlink
  # from "storm.home"/logs/ to the actual $log_dir.  This is required because as of Sep 2013
  # (and Storm 0.9.0-wip21) the log directory is still hardcoded in same places in the Storm
  # code.  Otherwise we could just supply a custom "storm.home"/logback/cluster.xml config.
  # See https://groups.google.com/forum/#!topic/storm-user/IKRtIkqQfqc for details.
  $storm_rpm_log_dir = $storm::params::log_dir
  if $log_dir != $storm_rpm_log_dir {
    exec { 'create-storm-log-directory':
      command => "mkdir -p ${log_dir}",
      path    => ['/bin', '/sbin'],
      require => Package['storm'],
    }
    ->
    file { $log_dir:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0750',
    }
    ->
    file { $storm_rpm_log_dir:
      ensure => link,
      target => $log_dir,
      force   => true,
    }
  }
  else {
    file { $storm_rpm_log_dir:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => '0750',
      require => Package['storm'],
    }
  }

}