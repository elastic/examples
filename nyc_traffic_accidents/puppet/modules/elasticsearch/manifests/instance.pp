# == Define: elasticsearch::instance
#
#  This define allows you to create or remove an elasticsearch instance
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
# [*config*]
#   Elasticsearch configuration hash
#
# [*configdir*]
#   Path to directory containing the elasticsearch configuration.
#   Use this setting if your packages deviate from the norm (/etc/elasticsearch)
#
# [*datadir*]
#   Allows you to set the data directory of Elasticsearch
#
# [*logging_file*]
#   Instead of a hash you can supply a puppet:// file source for the logging.yml file
#
# [*logging_cnofig*]
#   Hash representation of information you want in the logging.yml file
#
# [*logging_level*]
#   Default logging level for Elasticsearch.
#   Defaults to: INFO
#
# [*init_defaults*]
#   Defaults file content in hash representation
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
define elasticsearch::instance(
  $ensure         = $elasticsearch::ensure,
  $status         = $elasticsearch::status,
  $config         = undef,
  $configdir      = undef,
  $datadir        = undef,
  $logging_file   = undef,
  $logging_config = undef,
  $logging_level  = $elasticsearch::default_logging_level,
  $init_defaults  = undef
) {

  require elasticsearch
  require elasticsearch::params

  File {
    owner => $elasticsearch::elasticsearch_user,
    group => $elasticsearch::elasticsearch_group
  }

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  $notify_service = $elasticsearch::restart_on_change ? {
    true  => Elasticsearch::Service[$name],
    false => undef,
  }

  # Instance config directory
  if ($configdir == undef) {
    $instance_configdir = "${elasticsearch::configdir}/${name}"
  } else {
    $instance_configdir = $configdir
  }

  if ($ensure == 'present') {

    # Configuration hash
    if ($config == undef) {
      $instance_config = {}
    } else {
      validate_hash($config)
      $instance_config = $config
    }

    if(has_key($instance_config, 'node.name')) {
      $instance_node_name = {}
    } elsif(has_key($instance_config,'node')) {
      if(has_key($instance_config['node'], 'name')) {
        $instance_node_name = {}
      } else {
        $instance_node_name = { 'node.name' => "${::hostname}-${name}" }
      }
    } else {
      $instance_node_name = { 'node.name' => "${::hostname}-${name}" }
    }

    # String or array for data dir(s)
    if ($datadir == undef) {
      if (is_array($elasticsearch::datadir)) {
        $instance_datadir = array_suffix($elasticsearch::datadir, "/${name}")
      } else {
        $instance_datadir = "${elasticsearch::datadir}/${name}"
      }
    } else {
      $instance_datadir = $datadir
    }

    # Logging file or hash
    if ($logging_file != undef) {
      $logging_source = $logging_file
      $logging_content = undef
    } elsif ($elasticsearch::logging_file != undef) {
      $logging_source = $elasticsearch::logging_file
      $logging_content = undef
    } else {

      if(is_hash($elasticsearch::logging_config)) {
        $main_logging_config = $elasticsearch::logging_config
      } else {
        $main_logging_config = { }
      }

      if(is_hash($logging_config)) {
        $instance_logging_config = $logging_config
      } else {
        $instance_logging_config = { }
      }
      $logging_hash = merge($elasticsearch::params::logging_defaults, $main_logging_config, $instance_logging_config)
      $logging_content = template("${module_name}/etc/elasticsearch/logging.yml.erb")
      $logging_source = undef
    }

    $instance_datadir_config = { 'path.data' => $instance_datadir }

    if(is_array($instance_datadir)) {
      $dirs = join($instance_datadir, ' ')
    } else {
      $dirs = $instance_datadir
    }

    exec { "mkdir_datadir_elasticsearch_${name}":
      command => "mkdir -p ${dirs}",
      creates => $instance_datadir,
      require => Class['elasticsearch::package'],
      before  => Elasticsearch::Service[$name]
    }

    file { $instance_datadir:
      ensure  => 'directory',
      owner   => $elasticsearch::elasticsearch_user,
      group   => $elasticsearch::elasticsearch_group,
      mode    => '0770',
      require => [ Exec["mkdir_datadir_elasticsearch_${name}"], Class['elasticsearch::package'] ],
      before  => Elasticsearch::Service[$name]
    }

    exec { "mkdir_configdir_elasticsearch_${name}":
      command => "mkdir -p ${instance_configdir}",
      creates => $elasticsearch::configdir,
      require => Class['elasticsearch::package'],
      before  => Elasticsearch::Service[$name]
    }

    file { $instance_configdir:
      ensure  => 'directory',
      mode    => '0644',
      purge   => $elasticsearch::purge_configdir,
      force   => $elasticsearch::purge_configdir,
      require => [ Exec["mkdir_configdir_elasticsearch_${name}"], Class['elasticsearch::package'] ],
      before  => Elasticsearch::Service[$name]
    }

    file { "${instance_configdir}/logging.yml":
      ensure  => file,
      content => $logging_content,
      source  => $logging_source,
      mode    => '0644',
      notify  => $notify_service,
      require => Class['elasticsearch::package'],
      before  => Elasticsearch::Service[$name]
    }

    $require = Class['elasticsearch::package']
    $before = undef

    # build up new config
    $instance_conf = merge($elasticsearch::config, $instance_node_name, $instance_config, $instance_datadir_config)

    # defaults file content
    if (is_hash($elasticsearch::init_defaults)) {
      $global_init_defaults = $elasticsearch::init_defaults
    } else {
      $global_init_defaults = { }
    }

    $instance_init_defaults_main = { 'CONF_DIR' => $instance_configdir, 'CONF_FILE' => "${instance_configdir}/elasticsearch.yml", 'LOG_DIR' => "/var/log/elasticsearch/${name}", 'ES_HOME' => '/usr/share/elasticsearch' }

    if (is_hash($init_defaults)) {
      $instance_init_defaults = $init_defaults
    } else {
      $instance_init_defaults = { }
    }
    $init_defaults_new = merge($global_init_defaults, $instance_init_defaults_main, $instance_init_defaults )

    $user = $elasticsearch::elasticsearch_user
    $group = $elasticsearch::elasticsearch_group

    file { "${instance_configdir}/elasticsearch.yml":
      ensure  => file,
      content => template("${module_name}/etc/elasticsearch/elasticsearch.yml.erb"),
      mode    => '0644',
      notify  => $notify_service,
      require => Class['elasticsearch::package']
    }

  } else {

    file { $instance_configdir:
      ensure  => 'absent',
      recurse => true,
      force   => true,
      before  => Elasticsearch::Service[$name]
    }

    $require = undef
    $before = Class['elasticsearch::config']

  }

  elasticsearch::service { $name:
    init_defaults => $init_defaults_new,
    init_template => "${module_name}/etc/init.d/${elasticsearch::params::init_template}",
    require       => $require,
    before        => $before
  }

}
