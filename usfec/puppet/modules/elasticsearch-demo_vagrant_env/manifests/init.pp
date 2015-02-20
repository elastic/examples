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

include apt

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
	# INSTALL ELK STACK
	############################################################################

	# Get latest Kibana
	exec { "/usr/bin/wget --timestamping https://download.elasticsearch.org/kibana/kibana/kibana-4.0.0-linux-x64.tar.gz":
	  alias => "kibana_latest_wget",
	  cwd => "/tmp",
	}

	file { "/opt/kibana-4.0.0-linux-x64.tar.gz":
	  ensure => present,
	  source => "/tmp/kibana-4.0.0-linux-x64.tar.gz",
	  alias => "kibana_dist_file",
	  require => [Exec["kibana_latest_wget"]], 
	}

	# Install logstash
	class { "logstash":
	  manage_repo  => true,
	  repo_version => "1.5",
	  status => 'disabled'
	}

	exec {"kibana_unzip":
	  command => "/bin/tar xzfv kibana-4.0.0-linux-x64.tar.gz",
	  cwd => "/opt",
	  require => File["kibana_dist_file"],
	}

	# Install elasticsearch
	class { "elasticsearch":
	  manage_repo  => true,
	  repo_version => "1.4",
	  java_install => true,
	  init_defaults => {
	    "ES_HEAP_SIZE" => "1024m",
	  },
	  config => {
	    "bootstrap.mlockall" => true,
	    "cluster.name" => "es_demo",
	    "node.name" => $::hostname,
	  },
	}
	
	# exec {"wait_for_es":
	#   require => Service["elasticsearch-es-01"],
	#   command => "/usr/bin/curl --retry 10 --retry-delay 10 http://localhost:9200/_cluster/health",
	# }

	# exec {"kibana":
	# 	command => "/opt/kibana-4.0.0-rc1-linux-x64/bin/kibana",
	# 	cwd => "/opt/kibana-4.0.0-rc1-linux-x64/",
	# 	require => Exec["wait_for_es"],
	# }

	# Install Marvel
	elasticsearch::plugin { "elasticsearch/marvel/latest":
	  module_dir => "marvel",
	  instances => [ 'es-01' ],
	}


	elasticsearch::instance { 'es-01': 
	  datadir => '/var/lib/es-data-es01'
	} 	
	
	# Service["elasticsearch-es-01"]->Exec["kibana"]

}
