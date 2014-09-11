require 'spec_helper'
describe 'apt' do
  context 'with sources defined on valid osfamily' do
    let :facts do
      { :osfamily        => 'Debian',
        :lsbdistcodename => 'precise',
        :lsbdistid       => 'Debian',
      }
    end
    let(:params) { { :sources => {
      'debian_unstable' => {
        'location'          => 'http://debian.mirror.iweb.ca/debian/',
        'release'           => 'unstable',
        'repos'             => 'main contrib non-free',
        'required_packages' => 'debian-keyring debian-archive-keyring',
        'key'               => '55BE302B',
        'key_server'        => 'subkeys.pgp.net',
        'pin'               => '-10',
        'include_src'       => true
      },
      'puppetlabs' => {
        'location'   => 'http://apt.puppetlabs.com',
        'repos'      => 'main',
        'key'        => '4BD6EC30',
        'key_server' => 'pgp.mit.edu',
      }
    } } }

    it {
      should contain_file('debian_unstable.list').with({
        'ensure'  => 'present',
        'path'    => '/etc/apt/sources.list.d/debian_unstable.list',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'notify'  => 'Exec[apt_update]',
      })
    }

    it { should contain_file('debian_unstable.list').with_content(/^deb http:\/\/debian.mirror.iweb.ca\/debian\/ unstable main contrib non-free$/) }
    it { should contain_file('debian_unstable.list').with_content(/^deb-src http:\/\/debian.mirror.iweb.ca\/debian\/ unstable main contrib non-free$/) }

    it {
      should contain_file('puppetlabs.list').with({
        'ensure'  => 'present',
        'path'    => '/etc/apt/sources.list.d/puppetlabs.list',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'notify'  => 'Exec[apt_update]',
      })
    }

    it { should contain_file('puppetlabs.list').with_content(/^deb http:\/\/apt.puppetlabs.com precise main$/) }
    it { should contain_file('puppetlabs.list').with_content(/^deb-src http:\/\/apt.puppetlabs.com precise main$/) }
  end

  context 'with unsupported osfamily' do
    let :facts do
      { :osfamily        => 'Darwin', }
    end

    it do
      expect {
       should compile
      }.to raise_error(Puppet::Error, /This module only works on Debian or derivatives like Ubuntu/)
    end
  end
end
