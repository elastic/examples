require 'spec_helper_system'


describe 'file should not replace' do
  shell('echo "file exists" >> /tmp/file')
  context 'should fail' do
    pp="
      concat { '/tmp/file':
        owner   => root,
        group   => root,
        mode    => '0644',
        replace => false,
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

  end
end
