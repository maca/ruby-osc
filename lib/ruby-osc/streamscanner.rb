# encoding: UTF-8
require 'strscan'

require 'ruby-osc/message'

module OSC
  class StreamScanner
    def initialize
      @scanner = StringScanner.new ""
    end

    def << arg
      if @scanner.string.frozen? #Bug? in ruby 1.8.7
        @scanner.string = @scanner.string + arg
      else
        @scanner << arg
      end
    end

    def tryparse
      # TODO check for bundle - use OSC.decode
      m = Message.decode_message @scanner
      @scanner.string = @scanner.rest
      return m
    end
  end
end
