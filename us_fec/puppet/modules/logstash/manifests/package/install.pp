# == Define: logstash::package::install
#
# This class exists to coordinate all software package management related
# actions, functionality and logical units in a central place.
#
#
# === Parameters
#
# [*package_url*]
#   Url to the contrib package to download.
#   This can be a http,https or ftp resource for remote packages
#   puppet:// resource or file:/ for local packages
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
define logstash::package::install(
  $package_url = undef
) {

  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
    tries     => 3,
    try_sleep => 10
  }

  #### Package management

  # set params: in operation
  if $logstash::ensure == 'present' {

    # Check if we want to install a specific version or not
    if $logstash::version == false {

      $package_ensure = $logstash::autoupgrade ? {
        true  => 'latest',
        false => 'present',
      }

    } else {

      # install specific version
      $package_ensure = $logstash::version

    }

    # action
    if ($package_url != undef) {

      case $logstash::software_provider {
        'package': { $before = Package[$name]  }
        default:   { fail("software provider \"${logstash::software_provider}\".") }
      }

      $package_dir = $logstash::package_dir

      $filenameArray = split($package_url, '/')
      $basefilename = $filenameArray[-1]

      $sourceArray = split($package_url, ':')
      $protocol_type = $sourceArray[0]

      $extArray = split($basefilename, '\.')
      $ext = $extArray[-1]

      $pkg_source = "${package_dir}/${basefilename}"

      case $protocol_type {

        puppet: {

          file { $pkg_source:
            ensure  => present,
            source  => $package_url,
            require => File[$package_dir],
            backup  => false,
            before  => $before
          }

        }
        ftp, https, http: {

          exec { "download_package_logstash_${name}":
            command => "${logstash::params::download_tool} ${pkg_source} ${package_url} 2> /dev/null",
            path    => ['/usr/bin', '/bin'],
            creates => $pkg_source,
            timeout => $logstash::package_dl_timeout,
            require => File[$package_dir],
            before  => $before
          }

        }
        file: {

          $source_path = $sourceArray[1]
          file { $pkg_source:
            ensure  => present,
            source  => $source_path,
            require => File[$package_dir],
            backup  => false,
            before  => $before
          }

        }
        default: {
          fail("Protocol must be puppet, file, http, https, or ftp. You have given \"${protocol_type}\"")
        }
      }

      if ($logstash::software_provider == 'package') {

        case $ext {
          'deb':   { $pkg_provider = 'dpkg'  }
          'rpm':   { $pkg_provider = 'rpm'   }
          default: { fail("Unknown file extention \"${ext}\".") }
        }

      }

    } else {
      $pkg_source      = undef
      $pkg_provider    = undef
    }

  } else { # Package removal
    $pkg_source     = undef
    $pkg_provider   = undef
    $package_ensure = 'purged'

  }

  if ($logstash::software_provider == 'package') {

    package { $name:
      ensure   => $package_ensure,
      source   => $pkg_source,
      provider => $pkg_provider
    }

  } else {
    fail("\"${logstash::software_provider}\" is not supported")
  }

}
