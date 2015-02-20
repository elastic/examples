require 'spec_helper'
describe 'demo_vagrant_env' do

  context 'with defaults for all parameters' do
    it { should contain_class('demo_vagrant_env') }
  end
end
