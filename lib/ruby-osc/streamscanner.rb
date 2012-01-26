# encoding: UTF-8
require 'strscan'
module OSC
  class StreamScanner
    def initialize
      @scanner = StringScanner.new ""
    end

    def << arg
      @scanner << arg
    end

    def tryparse
      m = Message.decode_message @scanner
      @scanner.string = @scanner.rest
      return m
    end
  end
end
