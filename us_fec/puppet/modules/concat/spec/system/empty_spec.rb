require 'spec_helper_system'

describe 'basic concat test' do
  context 'should run successfully' do
    pp="
      concat { '/tmp/file':
        owner => root,
        group => root,
        mode  => '0644',
        force => true,
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
      it { should_not contain '1\n2' }
    end
  end
end
