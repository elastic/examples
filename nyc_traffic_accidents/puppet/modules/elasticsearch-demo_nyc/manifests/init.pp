# == Class: demo_nyc
#
# Full description of class demo_nyc here.
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
#  class { demo_nyc:
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
class elasticsearch-demo_nyc {

	require elasticsearch-demo_vagrant_env


	############################################################################
	# DOWNLOAD SNAPSHOT
	############################################################################

	# Remove local snapshot archive to avoid naming conflicts while downloading remote snapshot archive
	exec { "sanitize_from_old_remainings":
	  command => "/bin/rm -f /vagrant/snapshot_demo_nyc_accidents.tar.gz",
	}

	exec { "get_data_from_download.elasticsearch.org":
	  command => "/usr/bin/wget https://download.elasticsearch.org/demos/nycopendata/snapshot_demo_nyc_accidents.tar.gz",
	  cwd => "/tmp",
	  timeout => 0,
	  require => [Exec["sanitize_from_old_remainings"]],
	}



	############################################################################
	# RESTORE SNAPSHOT
	############################################################################
	->
	exec {"create_es_dir":
	  command => "mkdir -p /tmp/elasticsearch",
	  path => ["/bin"],
	}
	->
	exec { "unzip_snapshot":
	  command => "tar xzfv /tmp/snapshot_demo_nyc_accidents.tar.gz",
	  cwd => "/tmp/elasticsearch",
	  path => ["/bin"],
	  require => [Exec["get_data_from_download.elasticsearch.org"]],
	}
	->
	exec {"register_snapshot":
	  command => "wget --spider --tries 10 --retry-connrefused --no-check-certificate http://localhost:9200 && curl -XPUT \'http://localhost:9200/_snapshot/snapshots\' -d \'{
	    \"type\": \"fs\",
	    \"settings\": {
	        \"location\": \"/tmp/elasticsearch/snapshots\",
	        \"compress\": true
	    }
	  }\'",
	  path => ["/usr/bin", "/bin"],
	}
	->
	exec {"restore_snapshot":
	  command => "curl -XPOST \'http://localhost:9200/_snapshot/snapshots/demo_nyc_accidents/_restore\'",
	  path => ["/usr/bin"],
	}

}
