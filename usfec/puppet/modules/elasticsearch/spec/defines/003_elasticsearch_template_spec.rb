require 'spec_helper'

describe 'elasticsearch::template', :type => 'define' do

  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat'
  } end

  let(:title) { 'foo' }
  let(:pre_condition) { 'class {"elasticsearch": config => { "node" => {"name" => "test" }}}'}

  context "Add a template" do

    let :params do {
      :ensure => 'present',
      :file   => 'puppet:///path/to/foo.json',
    } end

    it { should contain_elasticsearch__template('foo') }
    it { should contain_file('/etc/elasticsearch/templates_import/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json', :notify => "Exec[delete_template_foo]", :require => "Exec[mkdir_templates_elasticsearch]") }
    it { should contain_exec('insert_template_foo').with(:command => "curl -sL -w \"%{http_code}\\n\" -XPUT http://localhost:9200/_template/foo -d @/etc/elasticsearch/templates_import/elasticsearch-template-foo.json -o /dev/null | egrep \"(200|201)\" > /dev/null", :unless => 'test $(curl -s \'http://localhost:9200/_template/foo?pretty=true\' | wc -l) -gt 1') }
  end

  context "Delete a template" do

    let :params do {
      :ensure => 'absent'
    } end

    it { should contain_elasticsearch__template('foo') }
    it { should_not contain_file('/etc/elasticsearch/templates_import/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json') }
    it { should_not contain_exec('insert_template_foo') }
    it { should contain_exec('delete_template_foo').with(:command => 'curl -s -XDELETE http://localhost:9200/_template/foo', :notify => nil, :onlyif => 'test $(curl -s \'http://localhost:9200/_template/foo?pretty=true\' | wc -l) -gt 1' ) }
  end

  context "Add template with alternative host and port" do

    let :params do {
      :file => 'puppet:///path/to/foo.json',
      :host => 'otherhost',
      :port => '9201'
    } end

    it { should contain_elasticsearch__template('foo') }
    it { should contain_file('/etc/elasticsearch/templates_import/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json') }
    it { should contain_exec('insert_template_foo').with(:command => "curl -sL -w \"%{http_code}\\n\" -XPUT http://otherhost:9201/_template/foo -d @/etc/elasticsearch/templates_import/elasticsearch-template-foo.json -o /dev/null | egrep \"(200|201)\" > /dev/null", :unless => 'test $(curl -s \'http://otherhost:9201/_template/foo?pretty=true\' | wc -l) -gt 1') }
  end

  context "Add template using content" do

    let :params do {
      :content => '{"template":"*","settings":{"number_of_replicas":0}}'
    } end

    it { should contain_elasticsearch__template('foo') }
    it { should contain_file('/etc/elasticsearch/templates_import/elasticsearch-template-foo.json').with(:content => '{"template":"*","settings":{"number_of_replicas":0}}') }
  end

end
