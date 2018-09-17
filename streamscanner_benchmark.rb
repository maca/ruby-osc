require "benchmark"

$LOAD_PATH.unshift( File.join( File.dirname( __FILE__), "lib" ) )

require "ruby-osc/streamscanner"

@ss = OSC::StreamScanner.new

count = 10_000

Benchmark.bm(23) do |x|
  x.report("add new string") do
    count.times do
      @ss << "/bar/foo\000\000\000\000,iiii\000\000\000\000\000\000\004\000\000\000\003\000\000\000\002\000\000\000\001".force_encoding("binary")
    end
  end

  x.report("parse string") do
    count.times do
      @ss.tryparse
    end
  end


  x.report("try parse each message") do
    count.times do
      OSC::Message.decode("/bar/foo\000\000\000\000,iiii\000\000\000\000\000\000\004\000\000\000\003\000\000\000\002\000\000\000\001".force_encoding("binary"))
    end
  end

  x.report("parse failure") do
    count.times do
      begin
        @ss.tryparse
      rescue
        nil
      end
    end
  end
end
