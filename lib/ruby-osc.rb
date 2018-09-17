require "rubygems"
require "eventmachine"
require "socket" # Strange side effects with eventmachine udp client and SuperCollider
require "strscan"
require "thread"

$LOAD_PATH.unshift( File.join( File.dirname( __FILE__), "..", "lib" ) )

# encoding: UTF-8
require "ruby-osc/message"
require "ruby-osc/bundle"
require "ruby-osc/server"
require "ruby-osc/client"
require "ruby-osc/version"

module OSC
  class DecodeError < StandardError; end

  class Blob < String; end

  module OSCArgument
    def to_osc_type
      raise NotImplementedError, "#to_osc_type method should be implemented for #{ self.class }"
    end
  end

  def self.coerce_argument(arg)
    case arg
    when OSCArgument then arg.to_osc_type
    when Symbol      then arg.to_s
    when String, Float, Integer, Blob, String then arg # Osc 1.0 spec
    else
      raise(TypeError, "#{ arg.inspect } is not a valid Message argument")
    end
  end

  def self.decode(str) #:nodoc:
    str.match(/^#bundle/) ? Bundle.decode(str) : Message.decode(str)
  end

  def self.padding_size(size)
    (4 - (size) % 4) % 4
  end

  def self.run
    EM.run do
      EM.error_handler { |e| puts e }
      EM.set_quantum 5
      yield
    end
  end

  def self.encoding_directive(obj) #:nodoc:
    case obj
    when Float then [obj, "f", "g"]
    when Integer then [obj, "i", "N"]
    when Blob then [[obj.bytesize, obj], "b", "Na*x#{ padding_size obj.bytesize + 4 }"]
    when String then [obj, "s", "Z*x#{ padding_size obj.bytesize + 1 }"]
    when Time
      t1, fr = (obj.to_f + 2_208_988_800).divmod(1)
      t2 = (fr * (2**32)).to_i
      [[t1, t2], "t", "N2"]
    end
  end
end
