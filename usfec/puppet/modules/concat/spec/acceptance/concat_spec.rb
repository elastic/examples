require 'spec_helper_acceptance'

case fact('osfamily')
when 'AIX'
  username  = 'root'
  groupname = 'system'
when 'Darwin'
  username  = 'root'
  groupname = 'wheel'
when 'windows'
  username  = 'Administrator'
  groupname = 'Administrators'
else
  username  = 'root'
  groupname = 'root'
end

describe 'basic concat test', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  basedir = default.tmpdir('concat')

  shared_examples 'successfully_applied' do |pp|
    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  context 'owner/group' do
    pp = <<-EOS
      include concat::setup
      concat { '#{basedir}/file':
        owner => '#{username}',
        group => '#{groupname}',
        mode  => '0644',
      }

      concat::fragment { '1':
        target  => '#{basedir}/file',
        content => '1',
        order   => '01',
      }

      concat::fragment { '2':
        target  => '#{basedir}/file',
        content => '2',
        order   => '02',
      }
    EOS

    it_behaves_like 'successfully_applied', pp

    describe file("#{basedir}/file") do
      it { should be_file }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      # XXX file be_mode isn't supported on AIX
      it("should be mode 644", :unless => (fact('osfamily') == "AIX" or UNSUPPORTED_PLATFORMS.include?(fact('osfamily')))) {
        should be_mode 644
      }
      it { should contain '1' }
      it { should contain '2' }
    end
    describe file("#{default.puppet['vardir']}/concat/#{basedir.gsub('/','_')}_file/fragments/01_1") do
      it { should be_file }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      # XXX file be_mode isn't supported on AIX
      it("should be mode 644", :unless => (fact('osfamily') == "AIX" or UNSUPPORTED_PLATFORMS.include?(fact('osfamily')))) {
        should be_mode 644
      }
    end
    describe file("#{default.puppet['vardir']}/concat/#{basedir.gsub('/','_')}_file/fragments/02_2") do
      it { should be_file }
      it { should be_owned_by username }
      it { should be_grouped_into groupname }
      # XXX file be_mode isn't supported on AIX
      it("should be mode 644", :unless => (fact('osfamily') == "AIX" or UNSUPPORTED_PLATFORMS.include?(fact('osfamily')))) {
        should be_mode 644
      }
    end
  end
end
