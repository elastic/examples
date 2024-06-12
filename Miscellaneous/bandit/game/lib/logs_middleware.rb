require 'json'
require 'socket'

class Logs

  def initialize(app, options={})
    puts 'Init Logs'
    @app = app
    @options = options
    @options[:from] ||= Socket.gethostname
  end

  def call(env)
    start_time = Time.now
    begin
      response = @app.call(env)
    rescue Exception => e
      exception = e
    end
    log = {
      time: start_time.to_i,
      from: @options[:from],
      response:
       {
         body: response.body
       }
    }
    if exception
      log[:exception] = {
        message:   exception.message,
        backtrace: exception.backtrace
      }
    end
    @@logger.info(log.to_json)
    response
  end

end
