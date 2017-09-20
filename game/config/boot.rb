require 'bundler'
Bundler.setup
Bundler.require

require 'logger'
require './lib/logs_middleware.rb'
@@logger = Logger.new('/tmp/bandit.log')
@@logger.formatter = proc do |severity, datetime, prog, message|
  %Q|{timestamp: "#{datetime.to_s}", message: "#{message}"}\n|
end

require './app/app.rb'

