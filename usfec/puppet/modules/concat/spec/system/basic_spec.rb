require 'spec_helper_system'

# Here we put the more basic fundamental tests, ultra obvious stuff.
describe "basic tests:" do
  context 'make sure we have copied the module across' do
    # No point diagnosing any more if the module wasn't copied properly
    context shell 'ls /etc/puppet/modules/concat' do
      its(:stdout) { should =~ /Modulefile/ }
      its(:stderr) { should be_empty }
      its(:exit_code) { should be_zero }
    end
  end
end
