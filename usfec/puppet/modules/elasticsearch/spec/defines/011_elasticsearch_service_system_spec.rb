require 'spec_helper'

describe 'elasticsearch::service::systemd', :type => 'define' do

  let :facts do {
    :operatingsystem => 'OpenSuSE',
    :kernel => 'Linux',
    :osfamily => 'Suse'
  } end

  let(:title) { 'es-01' }
  let(:pre_condition) { 'class {"elasticsearch": config => { "node" => {"name" => "test" }}}' }

  context "Setup service" do

    let :params do {
      :ensure => 'present',
      :status => 'enabled'
    } end

    it { should contain_elasticsearch__service__systemd('es-01') }
    it { should contain_exec('systemd_reload_es-01').with(:command => '/bin/systemctl daemon-reload') }
    it { should contain_service('elasticsearch-instance-es-01').with(:ensure => 'running', :enable => true, :provider => 'systemd') }
  end

  context "Remove service" do

    let :params do {
      :ensure => 'absent'
    } end

    it { should contain_elasticsearch__service__systemd('es-01') }
    it { should contain_exec('systemd_reload_es-01').with(:command => '/bin/systemctl daemon-reload') }
    it { should contain_service('elasticsearch-instance-es-01').with(:ensure => 'stopped', :enable => false, :provider => 'systemd') }
  end

  context "unmanaged" do
    let :params do {
      :ensure => 'present',
      :status => 'unmanaged'
    } end

    it { should contain_elasticsearch__service__systemd('es-01') }
    it { should_not contain_service('elasticsearch-instance-es-01') }
    it { should_not contain_file('/usr/lib/systemd/system/elasticsearch-es-01.service') }
    it { should_not contain_file('/etc/sysconfig/elasticsearch-es-01') }

  end

  context "Defaults file" do

    context "Set via file" do
      let :params do {
        :ensure => 'present',
	:status => 'enabled',
	:init_defaults_file => 'puppet:///path/to/initdefaultsfile'
      } end

      it { should contain_file('/etc/sysconfig/elasticsearch-es-01').with(:source => 'puppet:///path/to/initdefaultsfile', :before => 'Service[elasticsearch-instance-es-01]') }
    end

    context "Set via hash" do
      let :params do {
        :ensure => 'present',
	:status => 'enabled',
	:init_defaults => {'ES_HOME' => '/usr/share/elasticsearch' }
      } end

      it { should contain_augeas('defaults_es-01').with(:incl => '/etc/sysconfig/elasticsearch-es-01', :changes => "set ES_GROUP 'elasticsearch'\nset ES_HOME '/usr/share/elasticsearch'\nset ES_USER 'elasticsearch'\nset MAX_OPEN_FILES '65535'\n", :before => 'Service[elasticsearch-instance-es-01]') }
    end

    context "No restart when 'restart_on_change' is false" do
      let(:pre_condition) { 'class {"elasticsearch": config => { "node" => {"name" => "test" }}, restart_on_change => false } ' }

      context "Set via file" do
        let :params do {
          :ensure => 'present',
	  :status => 'enabled',
	  :init_defaults_file => 'puppet:///path/to/initdefaultsfile'
        } end

        it { should contain_file('/etc/sysconfig/elasticsearch-es-01').with(:source => 'puppet:///path/to/initdefaultsfile', :notify => 'Exec[systemd_reload_es-01]', :before => 'Service[elasticsearch-instance-es-01]') }
      end

      context "Set via hash" do
        let :params do {
          :ensure => 'present',
  	  :status => 'enabled',
  	  :init_defaults => {'ES_HOME' => '/usr/share/elasticsearch' }
        } end

        it { should contain_augeas('defaults_es-01').with(:incl => '/etc/sysconfig/elasticsearch-es-01', :changes => "set ES_GROUP 'elasticsearch'\nset ES_HOME '/usr/share/elasticsearch'\nset ES_USER 'elasticsearch'\nset MAX_OPEN_FILES '65535'\n", :notify => 'Exec[systemd_reload_es-01]', :before => 'Service[elasticsearch-instance-es-01]') }
      end

    end

  end

  context "Init file" do
    let(:pre_condition) { 'class {"elasticsearch": config => { "node" => {"name" => "test" }} } ' }

    context "Via template" do
      let :params do {
        :ensure => 'present',
	:status => 'enabled',
	:init_template => 'elasticsearch/etc/init.d/elasticsearch.systemd.erb'
      } end

      it { should contain_file('/usr/lib/systemd/system/elasticsearch-es-01.service').with(:before => 'Service[elasticsearch-instance-es-01]') }
    end

    context "No restart when 'restart_on_change' is false" do
      let(:pre_condition) { 'class {"elasticsearch": config => { "node" => {"name" => "test" }}, restart_on_change => false } ' }

      let :params do {
        :ensure => 'present',
	:status => 'enabled',
	:init_template => 'elasticsearch/etc/init.d/elasticsearch.systemd.erb'
      } end

      it { should contain_file('/usr/lib/systemd/system/elasticsearch-es-01.service').with(:notify => 'Exec[systemd_reload_es-01]', :before => 'Service[elasticsearch-instance-es-01]') }

    end

  end

end
