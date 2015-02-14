# == Class: elasticsearch::package
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
#   class { 'elasticsearch::package': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class elasticsearch::package {

  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
    tries     => 3,
    try_sleep => 10
  }

  #### Package management

  # set params: in operation
  if $elasticsearch::ensure == 'present' {

    # Check if we want to install a specific version or not
    if $elasticsearch::version == false {

      $package_ensure = $elasticsearch::autoupgrade ? {
        true  => 'latest',
        false => 'present',
      }

    } else {

      # install specific version
      $package_ensure = $elasticsearch::version

    }

    # action
    if ($elasticsearch::package_url != undef) {

      case $elasticsearch::package_provider {
        'package': { $before = Package[$elasticsearch::package_name]  }
        default:   { fail("software provider \"${elasticsearch::package_provider}\".") }
      }

      $package_dir = $elasticsearch::package_dir

      # Create directory to place the package file
      exec { 'create_package_dir_elasticsearch':
        cwd     => '/',
        path    => ['/usr/bin', '/bin'],
        command => "mkdir -p ${elasticsearch::package_dir}",
        creates => $elasticsearch::package_dir;
      }

      file { $package_dir:
        ensure  => 'directory',
        purge   => $elasticsearch::purge_package_dir,
        force   => $elasticsearch::purge_package_dir,
        backup  => false,
        require => Exec['create_package_dir_elasticsearch'],
      }

      $filenameArray = split($elasticsearch::package_url, '/')
      $basefilename = $filenameArray[-1]

      $sourceArray = split($elasticsearch::package_url, ':')
      $protocol_type = $sourceArray[0]

      $extArray = split($basefilename, '\.')
      $ext = $extArray[-1]

      $pkg_source = "${package_dir}/${basefilename}"

      case $protocol_type {

        puppet: {

          file { $pkg_source:
            ensure  => present,
            source  => $elasticsearch::package_url,
            require => File[$package_dir],
            backup  => false,
            before  => $before
          }

        }
        ftp, https, http: {

          exec { 'download_package_elasticsearch':
            command => "${elasticsearch::params::download_tool} ${pkg_source} ${elasticsearch::package_url} 2> /dev/null",
            creates => $pkg_source,
            timeout => $elasticsearch::package_dl_timeout,
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

      if ($elasticsearch::package_provider == 'package') {

        case $ext {
          'deb':   { $pkg_provider = 'dpkg' }
          'rpm':   { $pkg_provider = 'rpm'  }
          default: { fail("Unknown file extention \"${ext}\".") }
        }

      }

    } else {
      $pkg_source = undef
      $pkg_provider = undef
    }

  # Package removal
  } else {

    $pkg_source = undef
    if ($::operatingsystem == 'OpenSuSE') {
      $pkg_provider = 'rpm'
    } else {
      $pkg_provider = undef
    }
    $package_ensure = 'absent'

    $package_dir = $elasticsearch::package_dir

    file { $package_dir:
      ensure => 'absent',
      purge  => true,
      force  => true,
      backup => false
    }

  }

  if ($elasticsearch::package_provider == 'package') {

    package { $elasticsearch::package_name:
      ensure   => $package_ensure,
      source   => $pkg_source,
      provider => $pkg_provider,
    }

  } else {
    fail("\"${elasticsearch::package_provider}\" is not supported")
  }

}
