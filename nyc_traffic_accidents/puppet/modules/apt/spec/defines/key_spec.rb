require 'spec_helper'

describe 'apt::key', :type => :define do
  let(:facts) { { :lsbdistid => 'Debian' } }
  GPG_KEY_ID = '4BD6EC30'

  let :title do
    GPG_KEY_ID
  end

  describe 'normal operation' do
    describe 'default options' do
      it 'contains the apt::key' do
        should contain_apt__key(title).with({
          :key    => title,
          :ensure => 'present',
        })
      end
      it 'contains the apt_key' do
        should contain_apt_key(title).with({
          :id                => title,
          :ensure            => 'present',
          :source            => nil,
          :server            => nil,
          :content           => nil,
          :keyserver_options => nil,
        })
      end
      it 'contains the apt_key present anchor' do
        should contain_anchor("apt_key #{title} present")
      end
    end

    describe 'title and key =>' do
      let :title do
        'puppetlabs'
      end

      let :params do {
        :key => GPG_KEY_ID,
      } end

      it 'contains the apt::key' do
        should contain_apt__key(title).with({
          :key    => GPG_KEY_ID,
          :ensure => 'present',
        })
      end
      it 'contains the apt_key' do
        should contain_apt_key(title).with({
          :id                => GPG_KEY_ID,
          :ensure            => 'present',
          :source            => nil,
          :server            => nil,
          :content           => nil,
          :keyserver_options => nil,
        })
      end
      it 'contains the apt_key present anchor' do
        should contain_anchor("apt_key #{GPG_KEY_ID} present")
      end
    end

    describe 'ensure => absent' do
      let :params do {
        :ensure => 'absent',
      } end

      it 'contains the apt::key' do
        should contain_apt__key(title).with({
          :key          => title,
          :ensure       => 'absent',
        })
      end
      it 'contains the apt_key' do
        should contain_apt_key(title).with({
          :id                => title,
          :ensure            => 'absent',
          :source            => nil,
          :server            => nil,
          :content           => nil,
          :keyserver_options => nil,
        })
      end
      it 'contains the apt_key absent anchor' do
        should contain_anchor("apt_key #{title} absent")
      end
    end

    describe 'key_content =>' do
      let :params do {
        :key_content => 'GPG key content',
      } end

      it 'contains the apt::key' do
        should contain_apt__key(title).with({
          :key         => title,
          :ensure      => 'present',
          :key_content => params[:key_content],
        })
      end
      it 'contains the apt_key' do
        should contain_apt_key(title).with({
          :id                => title,
          :ensure            => 'present',
          :source            => nil,
          :server            => nil,
          :content           => params[:key_content],
          :keyserver_options => nil,
        })
      end
      it 'contains the apt_key present anchor' do
        should contain_anchor("apt_key #{title} present")
      end
    end

    describe 'key_source =>' do
      let :params do {
        :key_source => 'http://apt.puppetlabs.com/pubkey.gpg',
      } end

      it 'contains the apt::key' do
        should contain_apt__key(title).with({
          :key         => title,
          :ensure      => 'present',
          :key_source => params[:key_source],
        })
      end
      it 'contains the apt_key' do
        should contain_apt_key(title).with({
          :id                => title,
          :ensure            => 'present',
          :source            => params[:key_source],
          :server            => nil,
          :content           => nil,
          :keyserver_options => nil,
        })
      end
      it 'contains the apt_key present anchor' do
        should contain_anchor("apt_key #{title} present")
      end
    end

    describe 'key_server =>' do
      let :params do {
        :key_server => 'pgp.mit.edu',
      } end

      it 'contains the apt::key' do
        should contain_apt__key(title).with({
          :key         => title,
          :ensure      => 'present',
          :key_server  => 'pgp.mit.edu',
        })
      end
      it 'contains the apt_key' do
        should contain_apt_key(title).with({
          :id                => title,
          :ensure            => 'present',
          :source            => nil,
          :server            => params[:key_server],
          :content           => nil,
          :keyserver_options => nil,
        })
      end
      it 'contains the apt_key present anchor' do
        should contain_anchor("apt_key #{title} present")
      end
    end

    describe 'key_options =>' do
      let :params do {
        :key_options => 'debug',
      } end

      it 'contains the apt::key' do
        should contain_apt__key(title).with({
          :key          => title,
          :ensure       => 'present',
          :key_options  => 'debug',
        })
      end
      it 'contains the apt_key' do
        should contain_apt_key(title).with({
          :id                => title,
          :ensure            => 'present',
          :source            => nil,
          :server            => nil,
          :content           => nil,
          :keyserver_options => params[:key_options],
        })
      end
      it 'contains the apt_key present anchor' do
        should contain_anchor("apt_key #{title} present")
      end
    end
  end

  describe 'validation' do
    context 'invalid key' do
      let :title do
        'Out of rum. Why? Why are we out of rum?'
      end
      it 'fails' do
        expect { subject }.to raise_error(/does not match/)
      end
    end

    context 'invalid source' do
      let :params do {
        :key_source => 'afp://puppetlabs.com/key.gpg',
      } end
      it 'fails' do
        expect { subject }.to raise_error(/does not match/)
      end
    end

    context 'invalid content' do
      let :params do {
        :key_content => [],
      } end
      it 'fails' do
        expect { subject }.to raise_error(/is not a string/)
      end
    end

    context 'invalid server' do
      let :params do {
        :key_server => 'two bottles of rum',
      } end
      it 'fails' do
        expect { subject }.to raise_error(/must be a valid domain name/)
      end
    end

    context 'invalid keyserver_options' do
      let :params do {
        :key_options => {},
      } end
      it 'fails' do
        expect { subject }.to raise_error(/is not a string/)
      end
    end
  end

  describe 'duplication' do
    context 'two apt::key resources for same key, different titles' do
      let :pre_condition do
        "apt::key { 'duplicate': key => #{title}, }"
      end

      it 'contains two apt::key resources' do
        should contain_apt__key('duplicate').with({
          :key    => title,
          :ensure => 'present',
        })
        should contain_apt__key(title).with({
          :key    => title,
          :ensure => 'present',
        })
      end

      it 'contains only a single apt_key' do
        should contain_apt_key('duplicate').with({
          :id                => title,
          :ensure            => 'present',
          :source            => nil,
          :server            => nil,
          :content           => nil,
          :keyserver_options => nil,
        })
        should_not contain_apt_key(title)
      end
    end

    context 'two apt::key resources, different ensure' do
      let :pre_condition do
        "apt::key { 'duplicate': key => #{title}, ensure => 'absent', }"
      end
      it 'informs the user of the impossibility' do
        expect { subject }.to raise_error(/already ensured as absent/)
      end
    end
  end
end
