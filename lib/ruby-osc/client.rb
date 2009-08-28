module OSC
  class Client
    
    def initialize port, address = 'localhost'
      @address, @port = address, port
      run
    end
    
    def run
      @connection = EventMachine.open_datagram_socket 'localhost', 0, Connection
    end

    def stop
      @connection.close_connection if @connection
    end

    def send item
      @connection.send_datagram item.encode, @address, @port 
    end
    
    class Connection < EventMachine::Connection #:nodoc:
    end
  end
end