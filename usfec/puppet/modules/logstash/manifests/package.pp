# == Class: logstash::package
#
# This class exists to coordinate all software package management related
# actions, functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'logstash::package': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class logstash::package {

  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
    tries     => 3,
    try_sleep => 10
  }

  #### Package management

  # set params: in operation
  if $logstash::ensure == 'present' {

    # action
    if ($logstash::package_url != undef) {

      $package_dir = $logstash::package_dir

      # Create directory to place the package file
      exec { 'create_package_dir_logstash':
        cwd     => '/',
        path    => ['/usr/bin', '/bin'],
        command => "mkdir -p ${logstash::package_dir}",
        creates => $logstash::package_dir;
      }

      file { $package_dir:
        ensure  => 'directory',
        purge   => $logstash::purge_package_dir,
        force   => $logstash::purge_package_dir,
        backup  => false,
        require => Exec['create_package_dir_logstash'],
      }

    }

  } else { # Package removal
    $package_dir = $logstash::package_dir

    file { $package_dir:
      ensure => 'absent',
      purge  => true,
      force  => true,
      backup => false
    }

  }

  #class { 'logstash::package::core': }
  logstash::package::install { 'logstash':
    package_url => $logstash::package_url
  }

  if ($logstash::install_contrib == true) {

    #class { 'logstash::package::contrib': }
    logstash::package::install { 'logstash-contrib':
      package_url => $logstash::contrib_package_url
    }

    # Ensure we install Core package before contrib
    #Class['logstash::package::core'] -> Class['logstash::package::contrib']
    Logstash::Package::Install['logstash'] -> Logstash::Package::Install['logstash-contrib']

  }

}
