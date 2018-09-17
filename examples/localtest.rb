require "rubygems"
require "ruby-osc"

include OSC

OSC.run do
  server = Server.new 9090
  client = Client.new 9090

  server.add_pattern(/.*/) do |*args|       # this will match any address
    p "/.*/:       #{ args.join(', ') }"
  end

  server.add_pattern %r{foo/.*} do |*args| # this will match any /foo node
    p "%r{foo/.*}: #{ args.join(', ') }"
  end

  server.add_pattern "/foo/bar" do |*args| # this will just match /foo/bar address
    p "'/foo/bar': #{ args.join(', ') }"
  end

  server.add_pattern "/exit" do |*_args|    # this will just match /exit address
    exit
  end


  client.send Message.new("/foo/bar", 1, 1.2, "a string")
  client.send Message.new("/foo/bar/zar", 1, 1.2, "a string")
  client.send Bundle.new(Time.now + 2, Message.new("/exit"))
end
