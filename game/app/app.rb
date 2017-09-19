# encoding: utf-8

class ArmedBandit
  FRUITS = %w{apple coconut banana avocado cherry fig lime mango pear pomelo}

  def call(env)
    fruits = activate!
    Rack::Response.new "Kibana armed bandit! #{fruits}"
  end

  def activate!
    Array.new(3) { FRUITS.sample }
  end
end
