require 'beaker-rspec'
require 'pry'
require 'securerandom'

def test_settings
  RSpec.configuration.test_settings
end

RSpec.configure do |c|
  c.add_setting :test_settings, :default => {}
end

files_dir = ENV['files_dir'] || '/home/jenkins/puppet'

proxy_host = ENV['BEAKER_PACKAGE_PROXY'] || ''

if !proxy_host.empty?
  gem_proxy = "http_proxy=#{proxy_host}" unless proxy_host.empty?

  hosts.each do |host|
    on host, "echo 'export http_proxy='#{proxy_host}'' >> /root/.bashrc"
    on host, "echo 'export https_proxy='#{proxy_host}'' >> /root/.bashrc"
    on host, "echo 'export no_proxy=\"localhost,127.0.0.1,localaddress,.localdomain.com,#{host.name}\"' >> /root/.bashrc"
  end
else
  gem_proxy = ''
end

hosts.each do |host|
  # Install Puppet
  if host.is_pe?
    install_pe
  else
    puppetversion = ENV['VM_PUPPET_VERSION']
    on host, "#{gem_proxy} gem install puppet --no-ri --no-rdoc --version '~> #{puppetversion}'"
    on host, "mkdir -p #{host['distmoduledir']}"

    if fact('osfamily') == 'Suse'
      install_package host, 'rubygems ruby-devel augeas-devel libxml2-devel'
      on host, "#{gem_proxy} gem install ruby-augeas --no-ri --no-rdoc"
    end

  end

  case fact('osfamily')
    when 'RedHat'
      scp_to(host, "#{files_dir}/elasticsearch-1.3.1.noarch.rpm", '/tmp/elasticsearch-1.3.1.noarch.rpm')
    when 'Debian'
      case fact('lsbmajdistrelease')
        when '6'
          scp_to(host, "#{files_dir}/elasticsearch-1.1.0.deb", '/tmp/elasticsearch-1.1.0.deb')
        else
          scp_to(host, "#{files_dir}/elasticsearch-1.3.1.deb", '/tmp/elasticsearch-1.3.1.deb')
      end
    when 'Suse'
      case fact('operatingsystem')
        when 'OpenSuSE'
          scp_to(host, "#{files_dir}/elasticsearch-1.1.0.noarch.rpm", '/tmp/elasticsearch-1.1.0.noarch.rpm')
        else
          scp_to(host, "#{files_dir}/elasticsearch-1.3.1.noarch.rpm", '/tmp/elasticsearch-1.3.1.noarch.rpm')
      end
  end

  # on debian/ubuntu nodes ensure we get the latest info
  # Can happen we have stalled data in the images
  if fact('osfamily') == 'Debian'
    on host, "apt-get update"
  end

end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'elasticsearch')
    hosts.each do |host|

      copy_hiera_data_to(host, 'spec/fixtures/hiera/hieradata/')
      on host, puppet('module','install','puppetlabs-java'), { :acceptable_exit_codes => [0,1] }

      if ( host.is_pe? && host['pe_ver'] >= '3.7.0' ) || ! host.is_pe?
        scp_to(host, "#{files_dir}/puppetlabs-stdlib-3.2.0.tar.gz", '/tmp/puppetlabs-stdlib-3.2.0.tar.gz')
        on host, puppet('module','install','/tmp/puppetlabs-stdlib-3.2.0.tar.gz'), { :acceptable_exit_codes => [0,1] }
      end
      if fact('osfamily') == 'Debian'
        scp_to(host, "#{files_dir}/puppetlabs-apt-1.4.2.tar.gz", '/tmp/puppetlabs-apt-1.4.2.tar.gz')
        on host, puppet('module','install','/tmp/puppetlabs-apt-1.4.2.tar.gz'), { :acceptable_exit_codes => [0,1] }
      end
      if fact('osfamily') == 'Suse'
        on host, puppet('module','install','darin-zypprepo'), { :acceptable_exit_codes => [0,1] }
      end

    end
  end
end

require_relative 'spec_acceptance_common'
