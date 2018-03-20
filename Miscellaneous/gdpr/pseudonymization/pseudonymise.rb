require "openssl"

# register accepts the hashmap passed to "script_params"
# it runs once at startup
def register(params)
  @fields = params["fields"]
  @tag = params["tag"]
  @key = params["key"]
  @digest = OpenSSL::Digest::SHA256.new
end

# filter runs for every event
def filter(event)
  # process each field
  events = []
  @fields.each do |field|
    if event.get(field)
        val=event.get(field)
        hash=OpenSSL::HMAC.hexdigest(@digest, @key, val.to_s).force_encoding(Encoding::UTF_8)
        p=LogStash::Event.new();
        p.set('value',val);
        p.set('key',hash);
        p.tag(@tag);
        #spawn event
        events.push(p)
        #override original value
        event.set(field,hash);
     end

  end
  events.push(event)
  return events
end