# encoding: UTF-8
require 'socket' # Strange side effects with eventmachine udp client and SuperCollider

# From the Funaba osc gem:
module OSC
  class Client

    def initialize port, host = '127.0.0.1'
      @socket = UDPSocket.new
      @socket = UDPSocket.open
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
      @socket.connect host, port
    end

    def send mesg, *args
      @socket.send mesg.encode, 0
    end
  end
end

# module OSC
#   class Client
#
#     def initialize port, address = 'localhost'
#       @address, @port = address, port
#       run
#     end
#
#     def run
#       @connection = EventMachine.open_datagram_socket 'localhost', 0, Connection
#     end
#
#     def stop
#       @connection.close_connection if @connection
#     end
#
#     def send item
#       @connection.send_datagram item.encode, @address, @port
#     end
#
#     class Connection < EventMachine::Connection #:nodoc:
#     end
#   end
# end
