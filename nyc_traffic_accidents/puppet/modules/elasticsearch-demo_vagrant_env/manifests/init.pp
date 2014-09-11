# == Class: demo_vagrant_env
#
# Full description of class demo_vagrant_env here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { demo_vagrant_env:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class elasticsearch-demo_vagrant_env {

	############################################################################
	# SETUP BASIC ENVIRONMENT
	############################################################################


	# Default shell for users in Ubuntu is funky; 
	# tell Ubuntu to use bash instead
	user { "vagrant":
	  shell => "/bin/bash",
	}
	
	############################################################################
	# INSTALL WEBSERVER
	############################################################################

	# Install nginx
	class { 'nginx': }

	nginx::resource::vhost { "kibana_vhost":
	  listen_port => 5200,
	  www_root => "/var/www/kibana-3.1.0/",
	  index_files     => ['index.php', 'index.html', 'index.htm'],
	}

	nginx::resource::location { "kibana_root":
	  vhost => "kibana_vhost",
	  www_root => "/var/www/kibana-3.1.0/",
	}

	file { "/var/www":
	  alias => "var_www_dir",
	  ensure => directory,
	}
	
	############################################################################
	# INSTALL ELK STACK
	############################################################################

	# Get latest Kibana
	exec { "/usr/bin/wget --timestamping https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz":
	  alias => "kibana_latest_wget",
	  cwd => "/tmp",
	}

	file { "/var/www/kibana-3.1.0.tar.gz":
	  ensure => present,
	  source => "/tmp/kibana-3.1.0.tar.gz",
	  alias => "kibana_dist_file",
	  require => [File["var_www_dir"], Exec["kibana_latest_wget"]], 
	}

	# Install logstash
	class { "logstash":
	  manage_repo  => true,
	  repo_version => "1.4",
	  status => 'disabled'
	}

	exec {"kibana_unzip":
	  command => "/bin/tar xzfv kibana-3.1.0.tar.gz",
	  cwd => "/var/www",
	  require => File["kibana_dist_file"],
	}

	# Install elasticsearch
	class { "elasticsearch":
	  manage_repo  => true,
	  repo_version => "1.3",
	  init_defaults => {
	    "ES_HEAP_SIZE" => "1024m",
	  },
	  config => {
	    "bootstrap.mlockall" => true,
	    "cluster.name" => "es_demo",
	    "node.name" => $::hostname,
	  }
	}

	# Install Marvel
	elasticsearch::plugin { "elasticsearch/marvel/latest":
	  module_dir => "marvel",
	  instances => [ 'es-01' ],
	}


	elasticsearch::instance { 'es-01': 
	  datadir => '/var/lib/es-data-es01'
	} 	

}
