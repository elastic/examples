require 'spec_helper'

describe 'elasticsearch', :type => 'class' do

  context "Repo class" do

    let :facts do {
      :operatingsystem => 'CentOS',
      :kernel => 'Linux',
      :osfamily => 'RedHat'
    } end

    context "Use anchor type for ordering" do

      let :params do {
	:config => { },
        :manage_repo => true,
        :repo_version => '1.3'
      } end

      it { should contain_class('elasticsearch::repo').that_requires('Anchor[elasticsearch::begin]') }
    end


    context "Use stage type for ordering" do

      let :params do {
	:config => { },
        :manage_repo => true,
        :repo_version => '1.3',
        :repo_stage => 'setup'
      } end

      it { should contain_stage('setup') }
      it { should contain_class('elasticsearch::repo').with(:stage => 'setup') }

    end

  end

end
