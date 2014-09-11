# == Class: logstash::repo
#
# This class exists to install and manage yum and apt repositories
# that contain logstash official logstash packages
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
#   class { 'logstash::repo': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Phil Fenstermacher <mailto:phillip.fenstermacher@gmail.com>
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class logstash::repo {

  case $::osfamily {
    'Debian': {
      if !defined(Class['apt']) {
        class { 'apt': }
      }

      apt::source { 'logstash':
        location    => "http://packages.elasticsearch.org/logstash/${logstash::repo_version}/debian",
        release     => 'stable',
        repos       => 'main',
        key         => 'D88E42B4',
        key_server  => 'pgp.mit.edu',
        include_src => false,
      }
    }
    'RedHat': {
      yumrepo { 'logstash':
        descr    => 'Logstash Centos Repo',
        baseurl  => "http://packages.elasticsearch.org/logstash/${logstash::repo_version}/centos",
        gpgcheck => 1,
        gpgkey   => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
        enabled  => 1,
      }
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }
  }
}
