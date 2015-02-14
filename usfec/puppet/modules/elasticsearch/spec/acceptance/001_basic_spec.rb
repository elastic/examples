require 'spec_helper_acceptance'

# Here we put the more basic fundamental tests, ultra obvious stuff.
describe "basic tests:" do
  it 'make sure we have copied the module across' do
    shell("ls #{default['distmoduledir']}/elasticsearch/Modulefile", {:acceptable_exit_codes => 0})
  end
end
