module Puppet::Parser::Functions
  newfunction(:min, :type => :rvalue, :doc => <<-EOS
    Returns the lowest value of all arguments.
    Requires at least one argument.
    EOS
  ) do |args|

    raise(Puppet::ParseError, "min(): Wrong number of arguments " +
          "need at least one") if args.size == 0

    return args.min
  end
end
