module Puppet::Parser::Functions
  newfunction(:max, :type => :rvalue, :doc => <<-EOS
    Returns the highest value of all arguments.
    Requires at least one argument.
    EOS
  ) do |args|

    raise(Puppet::ParseError, "max(): Wrong number of arguments " +
          "need at least one") if args.size == 0

    return args.max
  end
end
