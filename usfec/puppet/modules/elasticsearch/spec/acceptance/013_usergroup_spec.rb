require 'spec_helper_acceptance'

describe "elasticsearch class:" do

  describe "Run as a different user" do

    it 'should run successfully' do
      shell("rm -rf /usr/share/elasticsearch")
      pp = "user { 'esuser': ensure => 'present', groups => ['esgroup', 'esuser'] }
            group { 'esuser': ensure => 'present' }
            group { 'esgroup': ensure => 'present' }
            class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, manage_repo => true, repo_version => '#{test_settings['repo_version']}', java_install => true, elasticsearch_user => 'esuser', elasticsearch_group => 'esgroup' }
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
      it { should be_owned_by 'esuser' }
      its(:content) { should match /[0-9]+/ }
    end

    describe "make sure elasticsearch can serve requests #{test_settings['port_a']}" do
      it {
        curl_with_retries("check ES on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
      }
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should be_owned_by 'esuser' }
      it { should contain 'name: elasticsearch001' }
    end

    describe file('/usr/share/elasticsearch') do
      it { should be_directory }
      it { should be_owned_by 'esuser' }
    end

    describe file('/var/log/elasticsearch') do
      it { should be_directory }
      it { should be_owned_by 'esuser' }
    end

    describe file('/etc/elasticsearch') do
      it { should be_directory }
      it { should be_owned_by 'esuser' }
    end


  end


  describe "Cleanup" do

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
