# == Define: elasticsearch::service::systemd
#
# This define exists to coordinate all service management related actions,
# functionality and logical units in a central place.
#
# <b>Note:</b> "service" is the Puppet term and type for background processes
# in general and is used in a platform-independent way. E.g. "service" means
# "daemon" in relation to Unix-like systems.
#
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed software packages are being uninstalled.
#   * Any traces of the packages will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*status*]
#   String to define the status of the service. Possible values:
#   * <tt>enabled</tt>: Service is running and will be started at boot time.
#   * <tt>disabled</tt>: Service is stopped and will not be started at boot
#     time.
#   * <tt>running</tt>: Service is running but will not be started at boot time.
#     You can use this to start a service on the first Puppet run instead of
#     the system startup.
#   * <tt>unmanaged</tt>: Service will not be started at boot time and Puppet
#     does not care whether the service is running or not. For example, this may
#     be useful if a cluster management software is used to decide when to start
#     the service plus assuring it is running on the desired node.
#   Defaults to <tt>enabled</tt>. The singular form ("service") is used for the
#   sake of convenience. Of course, the defined status affects all services if
#   more than one is managed (see <tt>service.pp</tt> to check if this is the
#   case).
#
# [*init_defaults*]
#   Defaults file content in hash representation
#
# [*init_defaults_file*]
#   Defaults file as puppet resource
#
# [*init_template*]
#   Service file as a template
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
define elasticsearch::service::systemd(
  $ensure             = $elasticsearch::ensure,
  $status             = $elasticsearch::status,
  $init_defaults_file = undef,
  $init_defaults      = undef,
  $init_template      = undef,
) {

  #### Service management

  # set params: in operation
  if $ensure == 'present' {

    case $status {
      # make sure service is currently running, start it on boot
      'enabled': {
        $service_ensure = 'running'
        $service_enable = true
      }
      # make sure service is currently stopped, do not start it on boot
      'disabled': {
        $service_ensure = 'stopped'
        $service_enable = false
      }
      # make sure service is currently running, do not start it on boot
      'running': {
        $service_ensure = 'running'
        $service_enable = false
      }
      # do not start service on boot, do not care whether currently running
      # or not
      'unmanaged': {
        $service_ensure = undef
        $service_enable = false
      }
      # unknown status
      # note: don't forget to update the parameter check in init.pp if you
      #       add a new or change an existing status.
      default: {
        fail("\"${status}\" is an unknown service status value")
      }
    }
  } else {
    # make sure the service is stopped and disabled (the removal itself will be
    # done by package.pp)
    $service_ensure = 'stopped'
    $service_enable = false
  }

  $notify_service = $elasticsearch::restart_on_change ? {
    true  => [ Exec['systemd_reload'], Service[$name] ],
    false => Exec['systemd_reload'],
  }

  if ( $status != 'unmanaged' and $ensure == 'present' ) {

    # defaults file content. Either from a hash or file
    if ($init_defaults_file != undef) {
      file { "${elasticsearch::params::defaults_location}/elasticsearch-${name}":
        ensure  => $ensure,
        source  => $init_defaults_file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        before  => Service[$name],
        notify  => $notify_service
      }

    } elsif ($init_defaults != undef and is_hash($init_defaults) ) {

      $init_defaults_pre_hash = { 'ES_USER' => $elasticsearch::elasticsearch_user, 'ES_GROUP' => $elasticsearch::elasticsearch_group }
      $new_init_defaults = merge($init_defaults_pre_hash, $init_defaults)

      augeas { "defaults_${name}":
        incl     => "${elasticsearch::params::defaults_location}/elasticsearch-${name}",
        lens     => 'Shellvars.lns',
        changes  => template("${module_name}/etc/sysconfig/defaults.erb"),
        before   => Service[$name],
        notify   => $notify_service
      }

    }

    # init file from template
    if ($init_template != undef) {

      file { "/usr/lib/systemd/system/elasticsearch-${name}.service":
        ensure  => $ensure,
        content => template($init_template),
        before  => Service[$name],
        notify  => $notify_service
      }

    }

  } elsif($status != 'unmanaged') {

    file { "/usr/lib/systemd/system/elasticsearch-${name}.service":
      ensure    => 'absent',
      subscribe => Service[$name],
      notify    => Exec['systemd_reload']
    }

    file { "${elasticsearch::params::defaults_location}/elasticsearch-${name}":
      ensure    => 'absent',
      subscribe => Service[$name]
    }

  }

  if(!defined(Exec['systemd_reload'])) {
    exec { 'systemd_reload':
      command     => '/bin/systemctl daemon-reload',
      refreshonly => true,
    }
  }

  if ($status != 'unmanaged') {

    # action
    service { $name:
      ensure     => $service_ensure,
      enable     => $service_enable,
      name       => "elasticsearch-${name}.service",
      hasstatus  => $elasticsearch::params::service_hasstatus,
      hasrestart => $elasticsearch::params::service_hasrestart,
      pattern    => $elasticsearch::params::service_pattern,
      provider   => 'systemd'
    }

  }

}
