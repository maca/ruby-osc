module OSC
  class Message
    attr_accessor :address, :time, :args

    def initialize(address = "", *args)
      args.collect! { |arg| OSC.coerce_argument arg }
      args.flatten! # won't harm we're not accepting arrays anyway, in case an custom coerced arg coerces to Array eg. Hash
      raise(TypeError, "Expected address to be a string") unless String === address
      @address, @args = address, args
    end

    def encode
      objs, tags, dirs = @args.collect { |arg| OSC.encoding_directive arg }.transpose
      dirs ||= [] and objs ||= []

      [",#{ tags and tags.join }", @address].each do |str|
        obj, _tag, dir = OSC.encoding_directive(str)
        objs.unshift obj
        dirs.unshift dir
      end

      objs.flatten.compact.pack dirs.join
    end

    def ==(other)
      self.class == other.class and to_a == other.to_a
    end

    def to_a; @args.dup.unshift(@address) end
    def to_s; "OSC::Message(#{ args.join(', ') })" end

    def self.decode(string)
      scanner        = StringScanner.new string
      msg            = decode_message scanner
      raise DecodeError unless scanner.eos?
      msg
    end

    def self.decode_message(scanner)
      pos = scanner.pos
      begin
        address, tags  = (1..2).map do
          string       = scanner.scan(/[^\000]+\000/)
          raise DecodeError, "no address or tags" if string.nil?
          scanner.pos += OSC.padding_size(string.bytesize)
          string.chomp("\000")
        end

        args = []
        tags.scan(/\w/) do |tag|
          case tag
          when "i"
            int = scanner.scan(/.{4}/nm).unpack("N").first
            args.push( int > (2**31 - 1) ? int - 2**32 : int )
          when "f"
            args.push scanner.scan(/.{4}/nm).unpack("g").first
          when "s"
            str = scanner.scan(/[^\000]+\000/)
            scanner.pos += OSC.padding_size(str.size)
            str = str.respond_to?(:force_encoding) ? str.force_encoding("UTF-8") : str
            args.push str.chomp("\000")
          when "b"
            size = scanner.scan(/.{4}/).unpack("N").first
            str  = scanner.scan(/.{#{ size }}/nm)
            scanner.pos += OSC.padding_size(size + 4)
            args.push Blob.new(str)
          else
            raise DecodeError, "#{ tag } is not a known tag"
          end
        end
        new address, *args
      end
    rescue DecodeError => e
      scanner.pos = pos
      raise e
    rescue => e
      scanner.pos = pos
      raise DecodeError, e
    end
  end
end
