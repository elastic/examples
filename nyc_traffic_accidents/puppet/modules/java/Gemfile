source "http://rubygems.org"

if ENV.key?('PUPPET_VERSION')
  puppetversion = "= #{ENV['PUPPET_VERSION']}"
elsif ENV.key?('PUPPET_GEM_VERSION')
  puppetversion = ENV['PUPPET_GEM_VERSION']
else
  puppetversion = ['~> 2.7']
end

gem "rake"
gem "puppet", puppetversion
gem "puppet-lint"
gem "rspec-puppet"
gem "puppetlabs_spec_helper"
