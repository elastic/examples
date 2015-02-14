require 'spec_helper_system'

describe 'basic concat test' do
  context 'should run successfully' do
    pp="
      concat { '/tmp/file':
        owner => root,
        group => root,
        mode  => '0644',
        warn  => true,
      }

      concat::fragment { '1':
        target  => '/tmp/file',
        content => '1',
        order   => '01',
      }

      concat::fragment { '2':
        target  => '/tmp/file',
        content => '2',
        order   => '02',
      }
    "

    context puppet_apply(pp) do
      its(:stderr) { should be_empty }
      its(:exit_code) { should_not == 1 }
      its(:refresh) { should be_nil }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end

    describe file('/tmp/file') do
      it { should be_file }
      it { should contain '# This file is managed by Puppet. DO NOT EDIT.' }
      it { should contain '1' }
      it { should contain '2' }
    end
  end
end
