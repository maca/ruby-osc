module OSC
  class Bundle < Array
    attr_accessor :timetag

    def initialize timetag = nil, *args
      args.each{ |arg| raise TypeError, "#{ arg.inspect } is required to be a Bundle or Message" unless Bundle === arg or Message === arg }
      raise TypeError, "#{ timetag.inspect } is required to be Time or nil" unless timetag == nil or Time === timetag
      super args
      @timetag = timetag
    end

    def encode
      timetag =
      if @timetag
        time, tag, dir = OSC.encoding_directive @timetag
        time.pack dir
      else "\000\000\000\000\000\000\000\001" end
        
      "#bundle\000#{ timetag }" + collect do |x|
        x = x.encode
        [x.size].pack('N') + x
      end.join
    end

    def self.decode string
      string.gsub! /^#bundle\000/, ''
      t1, t2, content_str = string.unpack('N2a*')
      
      timetag   = Time.at(t1 + t2 / (2**32.0) - 2_208_988_800) rescue nil
      scanner   = StringScanner.new content_str
      args      = []
      
      until scanner.eos?
        size    = scanner.scan(/.{4}/).unpack('N').first
        arg_str = scanner.scan(/.{#{ size }}/nm) rescue raise(DecodeError, "An error occured while trying to decode bad formatted osc bundle")
        args   << OSC.decode(arg_str)
      end
      
      new timetag, *args
    end
    
    def == other
      self.class == other.class and self.timetag == other.timetag and self.to_a == other.to_a
    end

    def to_a; Array.new self; end
    
    def to_s
      "OSC::Bundle(#{ self.join(', ') })"
    end
  end
end