# == Class: elasticsearch::config
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
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
#   class { 'elasticsearch::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class elasticsearch::config {

  #### Configuration

  File {
    owner => $elasticsearch::elasticsearch_user,
    group => $elasticsearch::elasticsearch_group
  }

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  if ( $elasticsearch::ensure == 'present' ) {

    $notify_service = $elasticsearch::restart_on_change ? {
      true  => Class['elasticsearch::service'],
      false => undef,
    }

    file { $elasticsearch::configdir:
      ensure => directory,
      mode   => '0644'
    }

    file { $elasticsearch::plugindir:
      ensure => 'directory',
      mode   => '0644'
    }

    exec { 'mkdir_templates_elasticsearch':
      command => "mkdir -p ${elasticsearch::configdir}/templates_import",
      creates => "${elasticsearch::configdir}/templates_import",
    }

    file { "${elasticsearch::configdir}/templates_import":
      ensure  => 'directory',
      mode    => '0644',
      require => [ Exec['mkdir_templates_elasticsearch'] ]
    }

  } elsif ( $elasticsearch::ensure == 'absent' ) {
    # don't remove anything for now
  }

}
