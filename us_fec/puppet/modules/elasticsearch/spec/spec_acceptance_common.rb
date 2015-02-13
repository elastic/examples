  test_settings['cluster_name'] = SecureRandom.hex(10)

  case fact('osfamily')
    when 'RedHat'
      test_settings['repo_version']    = '1.3'
      test_settings['url']             = 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.1.noarch.rpm'
      test_settings['local']           = '/tmp/elasticsearch-1.3.1.noarch.rpm'
      test_settings['puppet']          = 'elasticsearch-1.3.1.noarch.rpm'
      test_settings['package_name']    = 'elasticsearch'
      test_settings['service_name_a']  = 'elasticsearch-es-01'
      test_settings['service_name_b']  = 'elasticsearch-es-02'
      test_settings['pid_file_a']      = '/var/run/elasticsearch/elasticsearch-es-01.pid'
      test_settings['pid_file_b']      = '/var/run/elasticsearch/elasticsearch-es-02.pid'
      test_settings['defaults_file_a'] = '/etc/sysconfig/elasticsearch-es-01'
      test_settings['defaults_file_b'] = '/etc/sysconfig/elasticsearch-es-02'
      test_settings['port_a']          = '9200'
      test_settings['port_b']          = '9201'
    when 'Debian'
      case fact('lsbmajdistrelease')
        when '6'
	  test_settings['repo_version']    = '1.1'
	  test_settings['url']             = 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.deb'
	  test_settings['local']           = '/tmp/elasticsearch-1.1.0.deb'
	  test_settings['puppet']          = 'elasticsearch-1.1.0.deb'
        else
	  test_settings['repo_version']    = '1.3'
	  test_settings['url']             = 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.1.deb'
	  test_settings['local']           = '/tmp/elasticsearch-1.3.1.deb'
	  test_settings['puppet']          = 'elasticsearch-1.3.1.deb'
      end
      test_settings['package_name']    = 'elasticsearch'
      test_settings['service_name_a']  = 'elasticsearch-es-01'
      test_settings['service_name_b']  = 'elasticsearch-es-02'
      test_settings['pid_file_a']      = '/var/run/elasticsearch-es-01.pid'
      test_settings['pid_file_b']      = '/var/run/elasticsearch-es-02.pid'
      test_settings['defaults_file_a'] = '/etc/default/elasticsearch-es-01'
      test_settings['defaults_file_b'] = '/etc/default/elasticsearch-es-02'
      test_settings['port_a']          = '9200'
      test_settings['port_b']          = '9201'
    when 'Suse'
      case fact('operatingsystem')
        when 'OpenSuSE'
	  test_settings['repo_version']    = '1.1'
	  test_settings['url']             = 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.noarch.rpm'
	  test_settings['local']           = '/tmp/elasticsearch-1.1.0.noarch.rpm'
	  test_settings['puppet']          = 'elasticsearch-1.1.0.noarch.rpm'
        else
	  test_settings['repo_version']    = '1.3'
	  test_settings['url']             = 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.1.noarch.rpm'
	  test_settings['local']           = '/tmp/elasticsearch-1.3.1.noarch.rpm'
	  test_settings['puppet']          = 'elasticsearch-1.3.1.noarch.rpm'
      end
      test_settings['package_name']    = 'elasticsearch'
      test_settings['service_name_a']  = 'elasticsearch-es-01'
      test_settings['service_name_b']  = 'elasticsearch-es-02'
      test_settings['pid_file_a']      = '/var/run/elasticsearch/elasticsearch-es-01.pid'
      test_settings['pid_file_b']      = '/var/run/elasticsearch/elasticsearch-es-02.pid'
      test_settings['defaults_file_a'] = '/etc/sysconfig/elasticsearch-es-01'
      test_settings['defaults_file_b'] = '/etc/sysconfig/elasticsearch-es-02'
      test_settings['port_a']          = '9200'
      test_settings['port_b']          = '9201'
  end

  test_settings['datadir_1'] = '/var/lib/elasticsearch-data/1/'
  test_settings['datadir_2'] = '/var/lib/elasticsearch-data/2/'
  test_settings['datadir_3'] = '/var/lib/elasticsearch-data/3/'

  test_settings['good_json']='{
    "template" : "logstash-*",
    "settings" : {
      "index.refresh_interval" : "5s",
      "analysis" : {
	"analyzer" : {
	  "default" : {
	    "type" : "standard",
	    "stopwords" : "_none_"
	  }
	}
      }
    },
    "mappings" : {
      "_default_" : {
	 "_all" : {"enabled" : true},
	 "dynamic_templates" : [ {
	   "string_fields" : {
	     "match" : "*",
	     "match_mapping_type" : "string",
	     "mapping" : {
	       "type" : "multi_field",
		 "fields" : {
		   "{name}" : {"type": "string", "index" : "analyzed", "omit_norms" : true },
		   "raw" : {"type": "string", "index" : "not_analyzed", "ignore_above" : 256}
		 }
	     }
	   }
	 } ],
	 "properties" : {
	   "@version": { "type": "string", "index": "not_analyzed" },
	   "geoip"  : {
	     "type" : "object",
	       "dynamic": true,
	       "path": "full",
	       "properties" : {
		 "location" : { "type" : "geo_point" }
	       }
	   }
	 }
      }
    }
  }'

  test_settings['bad_json']='{
    "settings" : {
      "index.refresh_interval" : "5s",
      "analysis" : {
	"analyzer" : {
	  "default" : {
	    "type" : "standard",
	    "stopwords" : "_none_"
	  }
	}
      }
    },
    "mappings" : {
      "_default_" : {
	 "_all" : {"enabled" : true},
	 "dynamic_templates" : [ {
	   "string_fields" : {
	     "match" : "*",
	     "match_mapping_type" : "string",
	     "mapping" : {
	       "type" : "multi_field",
		 "fields" : {
		   "{name}" : {"type": "string", "index" : "analyzed", "omit_norms" : true },
		   "raw" : {"type": "string", "index" : "not_analyzed", "ignore_above" : 256}
		 }
	     }
	   }
	 } ],
	 "properties" : {
	   "@version": { "type": "string", "index": "not_analyzed" },
	   "geoip"  : {
	     "type" : "object",
	       "dynamic": true,
	       "path": "full",
	       "properties" : {
		 "location" : { "type" : "geo_point" }
	       }
	   }
	 }
      }
    }
  }'

RSpec.configuration.test_settings = test_settings
