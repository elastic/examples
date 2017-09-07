# encoding: utf-8

class ArmedBandit
  def call(env)
    Rack::Response.new "Kibana armed bandit! ready?"
  end
end
