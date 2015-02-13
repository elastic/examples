require 'spec_helper_acceptance'

describe "elasticsearch template define:" do

  shell("mkdir -p #{default['distmoduledir']}/another/files")
  shell("echo '#{test_settings['good_json']}' >> #{default['distmoduledir']}/another/files/good.json")
  shell("echo '#{test_settings['bad_json']}' >> #{default['distmoduledir']}/another/files/bad.json")

  describe "Insert a template with valid json content" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{test_settings['cluster_name']}' }, manage_repo => true, repo_version => '#{test_settings['repo_version']}', java_install => true }
          elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' } }
          elasticsearch::template { 'foo': ensure => 'present', file => 'puppet:///modules/another/good.json' }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    it 'should report as existing in Elasticsearch' do
      curl_with_retries('validate template as installed', default, "http://localhost:#{test_settings['port_a']}/_template/foo | grep logstash", 0)
    end
  end

  if fact('puppetversion') =~ /3\.[2-9]\./
    describe "Insert a template with bad json content" do

      it 'run should fail' do
        pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{test_settings['cluster_name']}' }, manage_repo => true, repo_version => '#{test_settings['repo_version']}', java_install => true }
             elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' } }
             elasticsearch::template { 'foo': ensure => 'present', file => 'puppet:///modules/another/bad.json' }"

        apply_manifest(pp, :expect_failures => true)
      end

    end

  else
    # The exit codes have changes since Puppet 3.2x
    # Since beaker expectations are based on the most recent puppet code All runs on previous versions fails.
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

    describe package(test_settings['package_name']) do
      it { should_not be_installed }
    end

    describe service(test_settings['service_name_a']) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end


end
