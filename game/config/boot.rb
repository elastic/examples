require 'bundler'
Bundler.setup
Bundler.require

require 'logger'
@@logger = Logger.new('/tmp/log/bandit.log')

require './app/app.rb'

