# encoding: UTF-8
require 'rubygems'
require 'rspec'

$:.unshift( File.join( File.dirname( __FILE__), '..', 'lib' ) ) 

if RUBY_VERSION.to_f < 1.9
  class String
    def force_encoding x
      # Nothing
      self
    end
  end
end

require 'ruby-osc'
include OSC
