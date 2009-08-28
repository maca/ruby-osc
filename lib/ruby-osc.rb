
require 'rubygems'
require 'eventmachine'
require 'strscan'

$:.unshift( File.dirname( __FILE__ ) )

require 'ruby-osc/message'
require 'ruby-osc/bundle'
require 'ruby-osc/server'
require 'ruby-osc/client'

module OSC
  VERSION = '0.1.9'
  Thread  = EM.reactor_running? ? nil : Thread.new { EM.run }
  Thread.run if RUBY_VERSION.to_f >= 1.9
  EM.error_handler { |e| puts e }
  EM.set_quantum 5
  
  class DecodeError < StandardError; end
  class Blob < String; end
  
  def self.decode str #:nodoc:
    str.match(/^#bundle/) ? Bundle.decode(str) : Message.decode(str)
  end
  
  def self.encoding_directive obj #:nodoc:
    case obj
    when Float  then [obj, 'f', 'g']
    when Fixnum then [obj, 'i', 'N']
    when Blob   then [[obj.size, obj], 'b', "NZ*x#{ (4 - (obj.size + 1 % 4)) % 4 }"]
    when String then [obj, 's', "Z*x#{ (4 - (obj.size + 1 % 4)) % 4 }"]
    when Time
      t1, fr = (obj.to_f + 2208988800).divmod(1)
      t2 = (fr * (2**32)).to_i
      [[t1, t2], 't', 'N2']
    end
  end
end
