require 'bundler'
Bundler.setup
Bundler.require

require 'ougai'
require './lib/logs_middleware.rb'
@@logger = Ougai::Logger.new('/tmp/bandit.log')

require './app/app.rb'

