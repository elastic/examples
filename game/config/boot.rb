require 'bundler'
Bundler.setup
Bundler.require

require 'logger'
require './lib/logs_middleware.rb'

@@logger = Logger.new('/tmp/log/bandit.log')

require './app/app.rb'

