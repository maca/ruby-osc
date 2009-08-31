
module OSC
  class Server
    attr_accessor :port, :address

    def initialize port, address = 'localhost'
      @port, @address   = port, address
      @queue, @patterns = [], []
      @mutex = Mutex.new
      run
    end

    def run
      @connection = EventMachine.open_datagram_socket @address, @port, Connection, self
      check_queue
    end

    def stop
      return unless @connection
      @connection.close_connection
      @timer.cancel
    end

    def add_pattern pattern, &block
      raise ArgumentError.new("A block must be given") unless block
      @patterns << [pattern, block]
    end

    def delete_pattern pattern
      @patterns.delete pattern
    end

    def receive data
      case decoded = OSC.decode(data)
      when Bundle
        decoded.timetag.nil? ? decoded.each{ |m| dispatch m } : @mutex.synchronize{@queue.push(decoded)}
      when Message
        dispatch decoded
      end
      rescue => e 
        warn "Bad data received: #{ e }"
    end

    private
    def check_queue
      @timer = EventMachine::PeriodicTimer.new 0.002 do
        now  = Time.now
        @mutex.synchronize do
          @queue.delete_if do |bundle|
            bundle.each{ |m| dispatch m } if delete = now >= bundle.timetag
            delete
          end
        end
      end
    end

    def dispatch message
      @patterns.each do |pat, block| 
        block.call(*message.to_a) if pat === message.address
      end
    end

    class Connection < EventMachine::Connection #:nodoc:
      def initialize server
        @server = server
      end

      def receive_data data
        @server.receive(data) 
      end
    end
  end
end
