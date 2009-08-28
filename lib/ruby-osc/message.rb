module OSC
  class Message
    attr_accessor :address, :time, :args

    def initialize address = '', *args
      @address, @args = address, args
    end

    def encode
      objs, tags, dirs = @args.collect { |arg| OSC.encoding_directive arg }.transpose
      dirs ||= [] and objs ||= []
      
      [",#{ tags and tags.join }", @address].each do |str|
        obj, tag, dir = OSC.encoding_directive str
        objs.unshift obj
        dirs.unshift dir
      end
      
      objs.flatten.compact.pack dirs.join
    end
      
    def == other
      self.class == other.class and to_a == other.to_a
    end
    
    def to_a; @args.dup.unshift(@address) end
    
    def to_s; "OSC::Message(#{ args.join(', ') })" end
    
    class << self
      def decode string
        string.gsub! %r{((?:\w|,|/)+)(\000{1,4})} do # May include aditional chars
          %(#{ $1 }#{ "\000" * ($2.size - (4 - ($1.size % 4)) + 1) }) 
        end
        
        address, tags, args = string.unpack('Z*xZ*a*')
        dirs = decoding_directives tags
        new address, *coerce_args(args.unpack(dirs), tags)
      end
    
      private
      def decoding_directives tags
        tags.gsub(/\w/) do |t|
          case t
          when 'i' then 'N'
          when 'f' then 'g'
          when 's' then 'Z*'
          when 'b' then 'NZ*'
          else
            raise DecodeError, "#{t} is not a known tag"
          end
        end
      end

      def coerce_args args, tags
        coerced_args, index = [], 0
        tags.scan(/\w/) do |tag|
          arg = args[index]
          coerced_args <<
          case tag
          when 'i' then arg > (2**31-1) ? arg - 2**32 : arg
          when 'b'
            blob = Blob.new args[index += 1]
            raise DecodeError.new(%{Blob "#{ blob }" has not the expected size}) unless blob.size == arg
            blob
          when 't' then Time.at(arg + args[index += 1].to_f / (2**32) - 2208988800) rescue nil
          else arg end
          index += 1
        end
        coerced_args
      end
    end
  end
end