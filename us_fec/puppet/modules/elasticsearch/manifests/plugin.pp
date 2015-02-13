# == Define: elasticsearch::plugin
#
# This define allows you to install arbitrary Elasticsearch plugins
# either by using the default repositories or by specifying an URL
#
# All default values are defined in the elasticsearch::params class.
#
#
# === Parameters
#
# [*module_dir*]
#   Directory name where the module will be installed
#   Value type is string
#   Default value: None
#   This variable is required
#
# [*ensure*]
#   Whether the plugin will be installed or removed.
#   Set to 'absent' to ensure a plugin is not installed
#   Value type is string
#   Default value: present
#   This variable is optional
#
# [*url*]
#   Specify an URL where to download the plugin from.
#   Value type is string
#   Default value: None
#   This variable is optional
#
# [*proxy_host*]
#   Proxy host to use when installing the plugin
#   Value type is string
#   Default value: None
#   This variable is optional
#
# [*proxy_port*]
#   Proxy port to use when installing the plugin
#   Value type is number
#   Default value: None
#   This variable is optional
#
# [*instances*]
#   Specify all the instances related
#   value type is string or array
#
# === Examples
#
# # From official repository
# elasticsearch::plugin{'mobz/elasticsearch-head': module_dir => 'head'}
#
# # From custom url
# elasticsearch::plugin{ 'elasticsearch-jetty':
#  module_dir => 'elasticsearch-jetty',
#  url        => 'https://oss-es-plugins.s3.amazonaws.com/elasticsearch-jetty/elasticsearch-jetty-0.90.0.zip',
# }
#
# === Authors
#
# * Matteo Sessa <mailto:matteo.sessa@catchoftheday.com.au>
# * Dennis Konert <mailto:dkonert@gmail.com>
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
define elasticsearch::plugin(
    $module_dir,
    $instances,
    $ensure      = 'present',
    $url         = '',
    $proxy_host  = undef,
    $proxy_port  = undef,
) {

  include elasticsearch

  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
    user      => $elasticsearch::elasticsearch_user,
    tries     => 6,
    try_sleep => 10
  }

  $notify_service = $elasticsearch::restart_on_change ? {
    false   => undef,
    default => Elasticsearch::Service[$instances],
  }

  if ($module_dir != '') {
      validate_string($module_dir)
  } else {
      fail("module_dir undefined for plugin ${name}")
  }

  if ($proxy_host != undef and $proxy_port != undef) {
    $proxy = " -DproxyPort=${proxy_port} -DproxyHost=${proxy_host}"
  } else {
    $proxy = ''
  }

  if ($url != '') {
    validate_string($url)
    $install_cmd = "${elasticsearch::plugintool}${proxy} -install ${name} -url ${url}"
    $exec_rets = [0,1]
  } else {
    $install_cmd = "${elasticsearch::plugintool}${proxy} -install ${name}"
    $exec_rets = [0,]
  }

  case $ensure {
    'installed', 'present': {
      exec {"install_plugin_${name}":
        command => $install_cmd,
        creates => "${elasticsearch::plugindir}/${module_dir}",
        returns => $exec_rets,
        notify  => $notify_service,
        require => File[$elasticsearch::plugindir]
      }
    }
    default: {
      exec {"remove_plugin_${name}":
        command => "${elasticsearch::plugintool} --remove ${module_dir}",
        onlyif  => "test -d ${elasticsearch::plugindir}/${module_dir}",
        notify  => $notify_service,
      }
    }
  }
}
