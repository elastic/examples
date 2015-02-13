require 'spec_helper'

describe 'elasticsearch::plugin', :type => 'define' do

  let(:title) { 'mobz/elasticsearch-head' }
  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat'
  } end
  let(:pre_condition) { 'class {"elasticsearch": config => { "node" => {"name" => "test" }}}'}

  context "Add a plugin" do

    let :params do {
      :ensure     => 'present',
      :module_dir => 'head',
      :instances  => 'es-01'
    } end

    it { should contain_elasticsearch__plugin('mobz/elasticsearch-head') }
    it { should contain_exec('install_plugin_mobz/elasticsearch-head').with(:command => '/usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head', :creates => '/usr/share/elasticsearch/plugins/head', :notify => 'Elasticsearch::Service[es-01]') }
  end

  context "Remove a plugin" do

    let :params do {
      :ensure     => 'absent',
      :module_dir => 'head',
      :instances  => 'es-01'
    } end

    it { should contain_elasticsearch__plugin('mobz/elasticsearch-head') }
    it { should contain_exec('remove_plugin_mobz/elasticsearch-head').with(:command => '/usr/share/elasticsearch/bin/plugin --remove head', :onlyif => 'test -d /usr/share/elasticsearch/plugins/head', :notify => 'Elasticsearch::Service[es-01]') }
  end

  context "Use a proxy" do

    let :params do {
      :ensure     => 'present',
      :module_dir => 'head',
      :instances  => 'es-01',
      :proxy_host => 'my.proxy.com',
      :proxy_port => 3128
    } end

    it { should contain_elasticsearch__plugin('mobz/elasticsearch-head') }
    it { should contain_exec('install_plugin_mobz/elasticsearch-head').with(:command => '/usr/share/elasticsearch/bin/plugin -DproxyPort=3128 -DproxyHost=my.proxy.com -install mobz/elasticsearch-head', :creates => '/usr/share/elasticsearch/plugins/head', :notify => 'Elasticsearch::Service[es-01]') }
  end

end
