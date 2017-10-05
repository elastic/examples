require 'bundler'
Bundler.setup
Bundler.require

require 'ougai'
@@logger = Ougai::Logger.new('/tmp/log/bandit.log')

require './app/app.rb'

