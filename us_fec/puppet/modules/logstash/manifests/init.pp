# == Class: logstash
#
# This class is able to install or remove logstash on a node.
# It manages the status of the related service.
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
# [*autoupgrade*]
#   Boolean. If set to <tt>true</tt>, any managed package gets upgraded
#   on each Puppet run when the package provider is able to find a newer
#   version than the present one. The exact behavior is provider dependent.
#   Q.v.:
#   * Puppet type reference: {package, "upgradeable"}[http://j.mp/xbxmNP]
#   * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   Defaults to <tt>false</tt>.
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
# [*version*]
#   String to set the specific version you want to install.
#   Defaults to <tt>false</tt>.
#
# [*restart_on_change*]
#   Boolean that determines if the application should be automatically restarted
#   whenever the configuration changes. Disabling automatic restarts on config
#   changes may be desired in an environment where you need to ensure restarts
#   occur in a controlled/rolling manner rather than during a Puppet run.
#
#   Defaults to <tt>true</tt>, which will restart the application on any config
#   change. Setting to <tt>false</tt> disables the automatic restart.
#
# The default values for the parameters are set in logstash::params. Have
# a look at the corresponding <tt>params.pp</tt> manifest file if you need more
# technical information about them.
#
# [*package_url*]
#   Url to the package to download.
#   This can be a http,https or ftp resource for remote packages
#   puppet:// resource or file:/ for local packages
#
# [*contrib_package_url*]
#   Url to the contrib package to download.
#   This can be a http,https or ftp resource for remote packages
#   puppet:// resource or file:/ for local packages
#
# [*software_provider*]
#   Way to install the packages, currently only packages are supported.
#
# [*package_dir*]
#   Directory where the packages are downloaded to
#
# [*purge_package_dir*]
#   Purge package directory on removal
#
# [*package_dl_timeout*]
#   For http,https and ftp downloads you can set howlong the exec resource may take.
#   Defaults to: 600 seconds
#
# [*logstash_user*]
#   The user Logstash should run as. This also sets the file rights.
#
# [*logstash_group*]
#   The group logstash should run as. This also sets the file rights
#
# [*purge_configdir*]
#   Purge the config directory for any unmanaged files
#
# [*service_provider*]
#   Service provider to use. By Default when a single service provider is possibe that one is selected.
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
# [*java_install*]
#  Install java which is required for Logstash.
#  Defaults to: false
#
# [*java_package*]
#   If you like to install a custom java package, put the name here.
#
# [*manage_repo*]
#   Enable repo management by enabling our official repositories
#
# [*repo_version*]
#   Our repositories are versioned per major version (1.3, 1.4) select here which version you want
#
# [*configdir*]
#   Path to directory containing the logstash configuration.
#   Use this setting if your packages deviate from the norm (/etc/logstash)
#
# [*install_contrib*]
#  Enable installation of the contrib package
#
# === Examples
#
# * Installation, make sure service is running and will be started at boot time:
#     class { 'logstash': }
#
# * Removal/decommissioning:
#     class { 'logstash':
#       ensure => 'absent',
#     }
#
# * Install everything but disable service(s) afterwards
#     class { 'logstash':
#       status => 'disabled',
#     }
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class logstash(
  $ensure              = $logstash::params::ensure,
  $status              = $logstash::params::status,
  $restart_on_change   = $logstash::params::restart_on_change,
  $autoupgrade         = $logstash::params::autoupgrade,
  $version             = false,
  $software_provider   = 'package',
  $package_url         = undef,
  $contrib_package_url = undef,
  $package_dir         = $logstash::params::package_dir,
  $purge_package_dir   = $logstash::params::purge_package_dir,
  $package_dl_timeout  = $logstash::params::package_dl_timeout,
  $logstash_user       = $logstash::params::logstash_user,
  $logstash_group      = $logstash::params::logstash_group,
  $configdir           = $logstash::params::configdir,
  $purge_configdir     = $logstash::params::purge_configdir,
  $java_install        = false,
  $java_package        = undef,
  $service_provider    = 'init',
  $init_defaults       = undef,
  $init_defaults_file  = undef,
  $init_template       = undef,
  $manage_repo         = false,
  $repo_version        = false,
  $install_contrib     = false,
  $repo_stage          = false
) inherits logstash::params {

  anchor {'logstash::begin': }
  anchor {'logstash::end': }

  #### Validate parameters

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  # autoupgrade
  validate_bool($autoupgrade)

  # package download timeout
  if ! is_integer($package_dl_timeout) {
    fail("\"${package_dl_timeout}\" is not a valid number for 'package_dl_timeout' parameter")
  }

  # service status
  if ! ($status in [ 'enabled', 'disabled', 'running', 'unmanaged' ]) {
    fail("\"${status}\" is not a valid status parameter value")
  }

  # restart on change
  validate_bool($restart_on_change)

  # purge conf dir
  validate_bool($purge_configdir)

  if ! ($service_provider in $logstash::params::service_providers) {
    fail("\"${service_provider}\" is not a valid provider for \"${::operatingsystem}\"")
  }

  if ($package_url != undef and $version != false) {
    fail('Unable to set the version number when using package_url option.')
  }

  validate_bool($manage_repo)

  if ($manage_repo == true) {
    validate_string($repo_version)
  }

  #### Manage actions

  # package(s)
  class { 'logstash::package': }

  # configuration
  class { 'logstash::config': }

  # service(s)
  class { 'logstash::service': }

  if $java_install == true {
    # Install java
    class { 'logstash::java': }

    # ensure we first install java and then manage the service
    Anchor['logstash::begin']
    -> Class['logstash::java']
    -> Class['logstash::package']
  }

  if ($manage_repo == true) {

    if ($repo_stage == false) {
      # use anchor for ordering

      # Set up repositories
      class { 'logstash::repo': }

      # Ensure that we set up the repositories before trying to install
      # the packages
      Anchor['logstash::begin']
      -> Class['logstash::repo']
      -> Class['logstash::package']

    } else {
      # use staging for ordering

      if !(defined(Stage[$repo_stage])) {
        stage { $repo_stage:  before => Stage['main'] }
      }

      class { 'logstash::repo':
        stage => $repo_stage
      }
    }
  }

  #### Manage relationships

  if $ensure == 'present' {

    # we need the software before configuring it
    Anchor['logstash::begin']
    -> Class['logstash::package']
    -> Class['logstash::config']

    # we need the software and a working configuration before running a service
    Class['logstash::package'] -> Class['logstash::service']
    Class['logstash::config']  -> Class['logstash::service']

    Class['logstash::service'] -> Anchor['logstash::end']

  } else {

    # make sure all services are getting stopped before software removal
    Anchor['logstash::begin']
    -> Class['logstash::service']
    -> Class['logstash::package']
    -> Anchor['logstash::end']

  }

}
