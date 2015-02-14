require 'spec_helper_acceptance'

describe "Elasticsearch class:" do

  shell("mkdir -p #{default['distmoduledir']}/another/files")
  shell("cp #{test_settings['local']} #{default['distmoduledir']}/another/files/#{test_settings['puppet']}")

  context "install via http resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => '#{test_settings['url']}', java_install => true, config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{test_settings['cluster_name']}' } }
            elasticsearch::instance{ 'es-01': }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(test_settings['package_name']) do
      it { should be_installed }
    end

    describe file(test_settings['pid_file_a']) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    it 'make sure elasticsearch can serve requests' do
      curl_with_retries('check ES', default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
    end

    describe service(test_settings['service_name_a']) do
      it { should be_enabled }
      it { should be_running }
    end

  end

  context "Clean" do
    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe package(test_settings['package_name']) do
      it { should_not be_installed }
    end

    describe service(test_settings['service_name_a']) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  context "Install via local file resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => 'file:#{test_settings['local']}', java_install => true, config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{test_settings['cluster_name']}' } }
            elasticsearch::instance{ 'es-01': }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(test_settings['package_name']) do
      it { should be_installed }
    end

    describe file(test_settings['pid_file_a']) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    it 'make sure elasticsearch can serve requests' do
      curl_with_retries('check ES', default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
    end

    describe service(test_settings['service_name_a']) do
      it { should be_enabled }
      it { should be_running }
    end

  end

  context "Clean" do
    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe package(test_settings['package_name']) do
      it { should_not be_installed }
    end

    describe service(test_settings['service_name_a']) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  context "Install via Puppet resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => 'puppet:///modules/another/#{test_settings['puppet']}', java_install => true, config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{test_settings['cluster_name']}' } }
            elasticsearch::instance { 'es-01': }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(test_settings['package_name']) do
      it { should be_installed }
    end

    describe file(test_settings['pid_file_a']) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    it 'make sure elasticsearch can serve requests' do
      curl_with_retries('check ES', default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
    end

    describe service(test_settings['service_name_a']) do
      it { should be_enabled }
      it { should be_running }
    end

  end

  context "Clean" do
    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
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
