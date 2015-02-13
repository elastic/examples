require 'spec_helper'

describe 'elasticsearch', :type => 'class' do

  default_params = {
    :config  => { 'node.name' => 'foo' }
  }

  facts = {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat'
  }

  let (:params) do
    default_params.merge({ })
  end

  context "Hiera" do
  
    context 'when specifying instances to create' do

      context 'a single instance' do

        let (:facts) {
          facts.merge({
            :scenario => 'singleinstance'
          })
        }

        it { should contain_elasticsearch__instance('es-01').with(:config => { 'node.name' => 'es-01' }) }
        it { should contain_elasticsearch__service('es-01') }
        it { should contain_elasticsearch__service__init('es-01') }
        it { should contain_service('elasticsearch-instance-es-01') }
        it { should contain_augeas('defaults_es-01') }
        it { should contain_file('/etc/elasticsearch/es-01').with(:ensure => 'directory') }
        it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml') }
        it { should contain_file('/etc/elasticsearch/es-01/logging.yml') }
        it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
        it { should contain_file('/usr/share/elasticsearch/data/es-01') }
        it { should contain_file('/etc/init.d/elasticsearch-es-01') }

      end

      context 'multiple instances' do

        let (:facts) {
          facts.merge({
            :scenario => 'multipleinstances'
          })
        }

        it { should contain_elasticsearch__instance('es-01').with(:config => { 'node.name' => 'es-01' }) }
        it { should contain_elasticsearch__service('es-01') }
        it { should contain_elasticsearch__service__init('es-01') }
        it { should contain_service('elasticsearch-instance-es-01') }
        it { should contain_augeas('defaults_es-01') }
        it { should contain_exec('mkdir_configdir_elasticsearch_es-01') }
        it { should contain_file('/etc/elasticsearch/es-01').with(:ensure => 'directory') }
        it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml') }
        it { should contain_file('/etc/elasticsearch/es-01/logging.yml') }
        it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
        it { should contain_file('/usr/share/elasticsearch/data/es-01') }
        it { should contain_file('/etc/init.d/elasticsearch-es-01') }

        it { should contain_elasticsearch__instance('es-02').with(:config => { 'node.name' => 'es-02' }) }
        it { should contain_elasticsearch__service('es-02') }
        it { should contain_elasticsearch__service__init('es-02') }
        it { should contain_service('elasticsearch-instance-es-02') }
        it { should contain_augeas('defaults_es-02') }
        it { should contain_exec('mkdir_configdir_elasticsearch_es-02') }
        it { should contain_file('/etc/elasticsearch/es-02').with(:ensure => 'directory') }
        it { should contain_file('/etc/elasticsearch/es-02/elasticsearch.yml') }
        it { should contain_file('/etc/elasticsearch/es-02/logging.yml') }
        it { should contain_exec('mkdir_datadir_elasticsearch_es-02') }
        it { should contain_file('/usr/share/elasticsearch/data/es-02') }
        it { should contain_file('/etc/init.d/elasticsearch-es-02') }

      end

    end

    context 'when we haven\'t specfied any instances to create' do

      let (:facts) {
        facts
      }

      it { should_not contain_elasticsearch__instance }

    end

    # Hiera Plugin creation.

    context 'when specifying plugins to create' do

      let (:facts) {
        facts.merge({
          :scenario => 'singleplugin'
        })
      }

      it { should contain_elasticsearch__plugin('mobz/elasticsearch-head').with(:ensure => 'present', :module_dir => 'head', :instances => 'es-01') }

    end

    context 'when we haven\'t specified any plugins to create' do

      let (:facts) {
        facts
      }

      it { should_not contain_elasticsearch__plugin }

    end

    context "multiple instances using hiera_merge" do

      let (:params) {
        default_params.merge({
        :instances_hiera_merge => true
        })
      }

      let (:facts) {
        facts.merge({
          :common => 'defaultinstance',
          :scenario => 'singleinstance'
        })
      }

      it { should contain_elasticsearch__instance('default').with(:config => { 'node.name' => 'default' }) }
      it { should contain_elasticsearch__service('default') }
      it { should contain_elasticsearch__service__init('default') }
      it { should contain_service('elasticsearch-instance-default') }
      it { should contain_augeas('defaults_default') }
      it { should contain_exec('mkdir_configdir_elasticsearch_default') }
      it { should contain_file('/etc/elasticsearch/default').with(:ensure => 'directory') }
      it { should contain_file('/etc/elasticsearch/default/elasticsearch.yml') }
      it { should contain_file('/etc/elasticsearch/default/logging.yml') }
      it { should contain_exec('mkdir_datadir_elasticsearch_default') }
      it { should contain_file('/usr/share/elasticsearch/data/default') }
      it { should contain_file('/etc/init.d/elasticsearch-default') }

      it { should contain_elasticsearch__instance('es-01').with(:config => { 'node.name' => 'es-01' }) }
      it { should contain_elasticsearch__service('es-01') }
      it { should contain_elasticsearch__service__init('es-01') }
      it { should contain_service('elasticsearch-instance-es-01') }
      it { should contain_augeas('defaults_es-01') }
      it { should contain_exec('mkdir_configdir_elasticsearch_es-01') }
      it { should contain_file('/etc/elasticsearch/es-01').with(:ensure => 'directory') }
      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml') }
      it { should contain_file('/etc/elasticsearch/es-01/logging.yml') }
      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_file('/usr/share/elasticsearch/data/es-01') }
      it { should contain_file('/etc/init.d/elasticsearch-es-01') }

    end

  end

end
