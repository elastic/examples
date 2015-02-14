require 'spec_helper'

describe 'elasticsearch::instance', :type => 'define' do

  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat',
    :hostname => 'elasticsearch001'
  } end

  let(:title) { 'es-01' }
  let(:pre_condition) { 'class {"elasticsearch": }'  }

  context "Config file" do

    context "with nothing set" do

      let :params do {
        :config => { }
      } end

      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: elasticsearch001-es-01\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "set a value" do

      let :params do {
        :config => { 'node.name' => 'test'   }
      } end

      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: test\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "set a value to true" do

      let :params do {
        :config => { 'node' => { 'master' => true }  }
      } end

      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  master: true\n  name: elasticsearch001-es-01\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "set a value to false" do

      let :params do {
        :config => { 'node' => { 'data' => false }  }
      } end

      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  data: false\n  name: elasticsearch001-es-01\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "deeper hash and multiple keys" do

      let :params do {
        :config => { 'index' => { 'routing' => { 'allocation' => { 'include' => 'tag1', 'exclude' => [ 'tag2', 'tag3' ] } } }, 'node.name' => 'somename'  }
      } end

      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nindex: \n  routing: \n    allocation: \n      exclude: \n             - tag2\n             - tag3\n      include: tag1\nnode: \n  name: somename\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "Combination of full hash and shorted write up keys" do

      let :params do {
        :config => { 'node' => { 'name' => 'NodeName', 'rack' => 46 }, 'boostrap.mlockall' => true, 'cluster' => { 'name' => 'ClusterName', 'routing.allocation.awareness.attributes' => 'rack' }, 'discovery.zen' => { 'ping.unicast.hosts'=> [ "host1", "host2" ], 'minimum_master_nodes' => 3, 'ping.multicast.enabled' => false }, 'gateway' => { 'expected_nodes' => 4, 'recover_after_nodes' => 3 }, 'network.host' => '123.123.123.123' }
       } end

      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nboostrap: \n  mlockall: true\ncluster: \n  name: ClusterName\n  routing: \n    allocation: \n      awareness: \n        attributes: rack\ndiscovery: \n  zen: \n    minimum_master_nodes: 3\n    ping: \n      multicast: \n        enabled: false\n      unicast: \n        hosts: \n             - host1\n             - host2\ngateway: \n  expected_nodes: 4\n  recover_after_nodes: 3\nnetwork: \n  host: 123.123.123.123\nnode: \n  name: NodeName\n  rack: 46\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "merge Main class and instance configs together" do
      let(:pre_condition) { 'class {"elasticsearch": config => { "cluster.name" => "somename"} }' }
      let :params do {
        :config => { 'node.name' => 'NodeName' }
      } end

      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\ncluster: \n  name: somename\nnode: \n  name: NodeName\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "override main class confgi with instance config" do
      let(:pre_condition) { 'class {"elasticsearch": config => { "cluster.name" => "somename" } }'  }
      let :params do {
        :config => { 'node.name' => 'NodeName', 'cluster.name' => 'ClusterName' }
      } end

      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\ncluster: \n  name: ClusterName\nnode: \n  name: NodeName\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }
    end

    context "service restarts" do

      let :facts do {
        :operatingsystem => 'CentOS',
        :kernel => 'Linux',
        :osfamily => 'RedHat',
        :hostname => 'elasticsearch001'
      } end

      let(:title) { 'es-01' }
      context "does not restart when restart_on_change is false" do
        let :params do {
          :config => { 'node' => { 'name' => 'test' }  },
        } end
        let(:pre_condition) { 'class {"elasticsearch": config => { }, restart_on_change => false }'  }

        it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').without_notify }
      end

      context "should happen restart_on_change is true (default)" do
        let :params do {
          :config => { 'node' => { 'name' => 'test' }  },
        } end
        let(:pre_condition) { 'class {"elasticsearch": config => { }}'  }

        it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:notify => "Elasticsearch::Service[es-01]") }
      end

    end

  end

  context "Config dir" do

    let(:title) { 'es-01' }

    context "default" do
      let(:pre_condition) { 'class {"elasticsearch": }'  }
      it { should contain_exec('mkdir_configdir_elasticsearch_es-01') }
      it { should contain_file('/etc/elasticsearch/es-01').with(:ensure => 'directory') }
      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml') }
      it { should contain_file('/etc/elasticsearch/es-01/logging.yml') }
    end

    context "Set in main class" do
      let(:pre_condition) { 'class {"elasticsearch": configdir => "/etc/elasticsearch-config" }'  }

      it { should contain_exec('mkdir_configdir_elasticsearch_es-01') }
      it { should contain_file('/etc/elasticsearch-config').with(:ensure => 'directory') }
      it { should contain_file('/etc/elasticsearch-config/templates_import').with(:ensure => 'directory') }
      it { should contain_file('/etc/elasticsearch-config/es-01').with(:ensure => 'directory') }
      it { should contain_file('/etc/elasticsearch-config/es-01/elasticsearch.yml') }
      it { should contain_file('/etc/elasticsearch-config/es-01/logging.yml') }
    end

    context "set in instance" do
      let(:pre_condition) { 'class {"elasticsearch": }'  }
      let :params do {
        :configdir => '/etc/elasticsearch-config/es-01'
      } end

      it { should contain_exec('mkdir_configdir_elasticsearch_es-01') }
      it { should contain_file('/etc/elasticsearch').with(:ensure => 'directory') }
      it { should contain_file('/etc/elasticsearch-config/es-01').with(:ensure => 'directory') }
      it { should contain_file('/etc/elasticsearch-config/es-01/elasticsearch.yml') }
      it { should contain_file('/etc/elasticsearch-config/es-01/logging.yml') }
    end

  end

  context "Service" do
    let(:title) { 'es-01' }
    let(:pre_condition) { 'class {"elasticsearch": }'  }

    context "Debian based" do
      let :facts do {
        :operatingsystem => 'Debian',
        :kernel => 'Linux',
        :osfamily => 'Debian',
        :hostname => 'elasticsearch001'
      } end

      it { should contain_elasticsearch__service('es-01').with(:init_template => 'elasticsearch/etc/init.d/elasticsearch.Debian.erb', :init_defaults => {"CONF_DIR"=>"/etc/elasticsearch/es-01", "CONF_FILE"=>"/etc/elasticsearch/es-01/elasticsearch.yml", "LOG_DIR"=>"/var/log/elasticsearch/es-01", "ES_HOME"=>"/usr/share/elasticsearch"}) }
    end

    context "Redhat based" do
      let :facts do {
        :operatingsystem => 'CentOS',
        :kernel => 'Linux',
        :osfamily => 'RedHat',
        :hostname => 'elasticsearch001'
      } end

      it { should contain_elasticsearch__service('es-01').with(:init_template => 'elasticsearch/etc/init.d/elasticsearch.RedHat.erb', :init_defaults => {"CONF_DIR"=>"/etc/elasticsearch/es-01", "CONF_FILE"=>"/etc/elasticsearch/es-01/elasticsearch.yml", "LOG_DIR"=>"/var/log/elasticsearch/es-01", "ES_HOME"=>"/usr/share/elasticsearch"}) }
    end

    context "OpenSuse based" do
      let :facts do {
        :operatingsystem => 'OpenSuSE',
        :kernel => 'Linux',
        :osfamily => 'Suse',
        :hostname => 'elasticsearch001'
      } end

      it { should contain_elasticsearch__service('es-01').with(:init_template => 'elasticsearch/etc/init.d/elasticsearch.systemd.erb', :init_defaults => {"CONF_DIR"=>"/etc/elasticsearch/es-01", "CONF_FILE"=>"/etc/elasticsearch/es-01/elasticsearch.yml", "LOG_DIR"=>"/var/log/elasticsearch/es-01", "ES_HOME"=>"/usr/share/elasticsearch"}) }
    end

  end

  context "data directory" do
    let :facts do {
      :operatingsystem => 'CentOS',
      :kernel => 'Linux',
      :osfamily => 'RedHat',
      :hostname => 'elasticsearch001'
    } end

    let(:title) { 'es-01' }
    let(:pre_condition) { 'class {"elasticsearch": }'  }

    context "default" do
      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: elasticsearch001-es-01\npath: \n  data: /usr/share/elasticsearch/data/es-01\n" ) }
      it { should contain_file('/usr/share/elasticsearch/data/es-01').with( :ensure => 'directory') }
      it { should contain_file('/usr/share/elasticsearch/data').with( :ensure => 'directory') }
    end

    context "single from main config " do
      let(:pre_condition) { 'class {"elasticsearch": datadir => "/var/lib/elasticsearch-data" }'  }
      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: elasticsearch001-es-01\npath: \n  data: /var/lib/elasticsearch-data/es-01\n" ) }
      it { should contain_file('/var/lib/elasticsearch-data').with( :ensure => 'directory') }
      it { should contain_file('/var/lib/elasticsearch-data/es-01').with( :ensure => 'directory') }
    end

    context "single from instance config" do
      let(:pre_condition) { 'class {"elasticsearch": }'  }
      let :params do {
        :datadir => '/var/lib/elasticsearch/data'
      } end

      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: elasticsearch001-es-01\npath: \n  data: /var/lib/elasticsearch/data\n" ) }
      it { should contain_file('/var/lib/elasticsearch/data').with( :ensure => 'directory') }
    end

    context "multiple from main config" do
      let(:pre_condition) { 'class {"elasticsearch": datadir => [ "/var/lib/elasticsearch-data01", "/var/lib/elasticsearch-data02"] }'  }
      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: elasticsearch001-es-01\npath: \n  data: \n      - /var/lib/elasticsearch-data01/es-01\n      - /var/lib/elasticsearch-data02/es-01\n" ) }
      it { should contain_file('/var/lib/elasticsearch-data01').with( :ensure => 'directory') }
      it { should contain_file('/var/lib/elasticsearch-data01/es-01').with( :ensure => 'directory') }
      it { should contain_file('/var/lib/elasticsearch-data02').with( :ensure => 'directory') }
      it { should contain_file('/var/lib/elasticsearch-data02/es-01').with( :ensure => 'directory') }
    end

    context "multiple from instance config" do
      let(:pre_condition) { 'class {"elasticsearch": }'  }
      let :params do {
        :datadir => ['/var/lib/elasticsearch-data/01', '/var/lib/elasticsearch-data/02']
      } end

      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: elasticsearch001-es-01\npath: \n  data: \n      - /var/lib/elasticsearch-data/01\n      - /var/lib/elasticsearch-data/02\n" ) }
      it { should contain_file('/var/lib/elasticsearch-data/01').with( :ensure => 'directory') }
      it { should contain_file('/var/lib/elasticsearch-data/02').with( :ensure => 'directory') }
    end

   context "Conflicting setting path.data" do
     let(:pre_condition) { 'class {"elasticsearch": }'  }
     let :params do {
       :datadir => '/var/lib/elasticsearch/data',
       :config  => { 'path.data' => '/var/lib/elasticsearch/otherdata' }
     } end

      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: elasticsearch001-es-01\npath: \n  data: /var/lib/elasticsearch/data\n" ) }
      it { should contain_file('/var/lib/elasticsearch/data').with( :ensure => 'directory') }
      it { should_not contain_file('/var/lib/elasticsearch/otherdata').with( :ensure => 'directory') }
   end

   context "Conflicting setting path => data" do
     let(:pre_condition) { 'class {"elasticsearch": }'  }
     let :params do {
       :datadir => '/var/lib/elasticsearch/data',
       :config  => { 'path' => { 'data' => '/var/lib/elasticsearch/otherdata' } }
     } end

      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: elasticsearch001-es-01\npath: \n  data: /var/lib/elasticsearch/data\n" ) }
      it { should contain_file('/var/lib/elasticsearch/data').with( :ensure => 'directory') }
      it { should_not contain_file('/var/lib/elasticsearch/otherdata').with( :ensure => 'directory') }
   end

  end

  context "Logging" do

    let :facts do {
      :operatingsystem => 'CentOS',
      :kernel => 'Linux',
      :osfamily => 'RedHat',
      :hostname => 'elasticsearch001'
    } end

    let(:pre_condition) { 'class {"elasticsearch": }'  }

    context "default" do
      it { should contain_file('/etc/elasticsearch/es-01/logging.yml').with_content(/^logger.index.search.slowlog: TRACE, index_search_slow_log_file$/).with(:source => nil) }
    end

    context "from main class" do

      context "config" do
        let(:pre_condition) { 'class {"elasticsearch": logging_config => { "index.search.slowlog" => "DEBUG, index_search_slow_log_file" } }'  }

        it { should contain_file('/etc/elasticsearch/es-01/logging.yml').with_content(/^logger.index.search.slowlog: DEBUG, index_search_slow_log_file$/).with(:source => nil) }
      end

      context "logging file " do
        let(:pre_condition) { 'class {"elasticsearch": logging_file => "puppet:///path/to/logging.yml" }'  }

        it { should contain_file('/etc/elasticsearch/es-01/logging.yml').with(:source => 'puppet:///path/to/logging.yml', :content => nil) }
      end

    end

    context "from instance" do

      let(:pre_condition) { 'class {"elasticsearch": }'  }

      context "config" do
        let :params do {
          :logging_config => { 'index.search.slowlog' => 'INFO, index_search_slow_log_file' }
        } end

        it { should contain_file('/etc/elasticsearch/es-01/logging.yml').with_content(/^logger.index.search.slowlog: INFO, index_search_slow_log_file$/).with(:source => nil) }
      end

      context "logging file " do
        let :params do {
          :logging_file => 'puppet:///path/to/logging.yml'
        } end

        it { should contain_file('/etc/elasticsearch/es-01/logging.yml').with(:source => 'puppet:///path/to/logging.yml', :content => nil) }
      end

    end

  end

  context "running as an other user" do

    let :facts do {
      :operatingsystem => 'CentOS',
      :kernel => 'Linux',
      :osfamily => 'RedHat',
      :hostname => 'elasticsearch001'
    } end

    let(:pre_condition) { 'class {"elasticsearch": elasticsearch_user => "myesuser", elasticsearch_group => "myesgroup" }'  }

    it { should contain_file('/usr/share/elasticsearch/data/es-01').with(:owner => 'myesuser') }
    it { should contain_file('/etc/elasticsearch/es-01').with(:owner => 'myesuser', :group => 'myesgroup') }
    it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:owner => 'myesuser', :group => 'myesgroup') }
    it { should contain_file('/etc/elasticsearch/es-01/logging.yml').with(:owner => 'myesuser', :group => 'myesgroup') }
  end

    context "setting different service status then main class" do

    let(:pre_condition) { 'class {"elasticsearch": status => "enabled" }'  }

    context "staus option" do

      let :params do {
        :status => 'running'
      } end

      it { should contain_service('elasticsearch-instance-es-01').with(:ensure => 'running', :enable => false) }

    end

  end
end
