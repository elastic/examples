require 'spec_helper_acceptance'

describe "Data dir settings" do

  describe "Default data dir" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, manage_repo => true, repo_version => '#{test_settings['repo_version']}', java_install => true }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' } }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end


    describe service(test_settings['service_name_a']) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(test_settings['package_name']) do
      it { should be_installed }
    end

    describe file(test_settings['pid_file_a']) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe "Elasticsearch serves requests on" do
      it {
        curl_with_retries("check ES on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
      }
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain "/usr/share/elasticsearch/data/es-01" }
    end

     describe "Elasticsearch config has the data path" do
      it {
        curl_with_retries("check data path on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/_nodes?pretty=true | grep /usr/share/elasticsearch/data/es-01", 0)
      }

    end

    describe file('/usr/share/elasticsearch/data/es-01') do
      it { should be_directory }
    end

  end


  describe "Single data dir from main class" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, manage_repo => true, repo_version => '#{test_settings['repo_version']}', java_install => true, datadir => '/var/lib/elasticsearch-data' }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' } }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end


    describe service(test_settings['service_name_a']) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(test_settings['package_name']) do
      it { should be_installed }
    end

    describe file(test_settings['pid_file_a']) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe "Elasticsearch serves requests on" do
      it {
        curl_with_retries("check ES on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
      }
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain '/var/lib/elasticsearch-data/es-01' }
    end

     describe "Elasticsearch config has the data path" do
      it {
        curl_with_retries("check data path on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/_nodes?pretty=true | grep /var/lib/elasticsearch-data/es-01", 0)
      }

    end

    describe file('/var/lib/elasticsearch-data/es-01') do
      it { should be_directory }
    end

  end

  describe "module removal" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/elasticsearch/es-01') do
      it { should_not be_directory }
    end

    describe service(test_settings['service_name_a']) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  describe "Single data dir from instance config" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, manage_repo => true, repo_version => '#{test_settings['repo_version']}', java_install => true }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}'}, datadir => '#{test_settings['datadir_1']}' }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end


    describe service(test_settings['service_name_a']) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(test_settings['package_name']) do
      it { should be_installed }
    end

    describe file(test_settings['pid_file_a']) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe "Elasticsearch serves requests on" do
      it {
        curl_with_retries("check ES on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
      }
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain "#{test_settings['datadir_1']}" }
    end

     describe "Elasticsearch config has the data path" do
      it {
        curl_with_retries("check data path on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/_nodes?pretty=true | grep #{test_settings['datadir_1']}", 0)
      }
    end

    describe file(test_settings['datadir_1']) do
      it { should be_directory }
    end

  end

  describe "module removal" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/elasticsearch/es-01') do
      it { should_not be_directory }
    end

    describe service(test_settings['service_name_a']) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  describe "multiple data dir's from main class" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, manage_repo => true, repo_version => '#{test_settings['repo_version']}', java_install => true, datadir => [ '/var/lib/elasticsearch/01', '/var/lib/elasticsearch/02'] }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' } }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end


    describe service(test_settings['service_name_a']) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(test_settings['package_name']) do
      it { should be_installed }
    end

    describe file(test_settings['pid_file_a']) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe "Elasticsearch serves requests on" do
      it {
        curl_with_retries("check ES on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
      }
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain '/var/lib/elasticsearch/01/es-01' }
      it { should contain '/var/lib/elasticsearch/02/es-01' }
    end

     describe "Elasticsearch config has the data path" do
      it {
        curl_with_retries("check data path on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/_nodes?pretty=true | grep /var/lib/elasticsearch/01/es-01", 0)
      }
      it {
        curl_with_retries("check data path on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/_nodes?pretty=true | grep /var/lib/elasticsearch/02/es-01", 0)
      }

    end

    describe file('/var/lib/elasticsearch/01/es-01') do
      it { should be_directory }
    end

    describe file('/var/lib/elasticsearch/02/es-01') do
      it { should be_directory }
    end

  end

  describe "module removal" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/elasticsearch/es-01') do
      it { should_not be_directory }
    end

    describe service(test_settings['service_name_a']) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end


  describe "multiple data dir's from instance config" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, manage_repo => true, repo_version => '#{test_settings['repo_version']}', java_install => true }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' }, datadir => [ '#{test_settings['datadir_1']}', '#{test_settings['datadir_2']}'] }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end


    describe service(test_settings['service_name_a']) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(test_settings['package_name']) do
      it { should be_installed }
    end

    describe file(test_settings['pid_file_a']) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe "Elasticsearch serves requests on" do
      it {
        curl_with_retries("check ES on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
      }
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain "#{test_settings['datadir_1']}" }
      it { should contain "#{test_settings['datadir_2']}" }
    end

     describe "Elasticsearch config has the data path" do
      it {
        curl_with_retries("check data path on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/_nodes?pretty=true | grep #{test_settings['datadir_1']}", 0)
      }
      it {
        curl_with_retries("check data path on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/_nodes?pretty=true | grep #{test_settings['datadir_2']}", 0)
      }

    end

    describe file(test_settings['datadir_1']) do
      it { should be_directory }
    end

    describe file(test_settings['datadir_2']) do
      it { should be_directory }
    end

  end

  describe "module removal" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/elasticsearch/es-01') do
      it { should_not be_directory }
    end

    describe service(test_settings['service_name_a']) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

end
