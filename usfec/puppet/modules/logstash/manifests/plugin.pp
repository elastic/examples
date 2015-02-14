# == Define: logstash::plugin
#
# This define allows you to transport custom plugins to the Logstash instance
#
# All default values are defined in the logstashc::params class.
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
# [*source*]
#   Puppet file resource of the plugin file ( puppet:// )
#   Value type is string
#   Default value: None
#   This variable is required
#
# [*type*]
#   plugin type, can be 'input', 'output,' filter' or 'codec'.
#   Value type is string
#   Default value: None
#   This variable is required
#
# [*filename*]
#   if you would like the actual file name to be different then the source file name
#   Value type is string
#   This variable is optional
#
#
# === Examples
#
#     logstash::plugin { 'myplugin':
#       ensure => 'present',
#       type   => 'input',
#       source => 'puppet:///path/to/my/custom/plugin.rb'
#     }
#
#     or wil an other actual file name
#
#     logstash::plugin { 'myplugin':
#       ensure   => 'present',
#       type     => 'output',
#       source   => 'puppet:///path/to/my/custom/plugin_v1.rb',
#       filename => 'plugin.rb'
#     }
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
define logstash::plugin (
  $source,
  $type,
  $ensure = 'present',
  $filename = '',
){

  validate_re($source, '^puppet://', 'Source must be from a puppet fileserver (begin with puppet://)' )

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  if ! ($type in [ 'input', 'output', 'filter', 'codec' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  $plugins_dir = "${logstash::configdir}/plugins"

  $filename_real = $filename ? {
    ''      => inline_template('<%= @source.split("/").last %>'),
    default => $filename
  }

  file { "${plugins_dir}/logstash/${type}s/${filename_real}":
    ensure  => $ensure,
    owner   => $logstash::logstash_user,
    group   => $logstash::logstash_group,
    mode    => '0440',
    source  => $source,
  }

}
