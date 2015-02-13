require 'spec_helper'
describe 'demo_nyc' do

  context 'with defaults for all parameters' do
    it { should contain_class('demo_nyc') }
  end
end
