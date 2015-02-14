require 'spec_helper_acceptance'

describe "Service tests:" do

  describe "Make sure we can manage the defaults file" do

    context "Change the defaults file" do
      it 'should run successfully' do
        pp = "class { 'elasticsearch': manage_repo => true, repo_version => '#{test_settings['repo_version']}', java_install => true, config => { 'cluster.name' => '#{test_settings['cluster_name']}' }, init_defaults => { 'ES_JAVA_OPTS' => '\"-server -XX:+UseTLAB -XX:+CMSClassUnloadingEnabled\"' } }
              elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001' } }
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

      describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
        it { should be_file }
        it { should contain 'name: elasticsearch001' }
      end

      describe 'make sure elasticsearch can serve requests' do
        it {
          curl_with_retries('check ES', default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
        }
      end

      context "Make sure we have ES_USER=root" do

        describe file(test_settings['defaults_file_a']) do
          its(:content) { should match /^ES_JAVA_OPTS="-server -XX:\+UseTLAB -XX:\+CMSClassUnloadingEnabled"/ }
        end

      end

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
