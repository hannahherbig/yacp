require 'json'
require 'rsa'
require 'bindata'

require 'logger'
require 'socket'

class Server
  attr_reader :sockets, :logger

  def initialize(host, port, debug=false)
    @sockets = Socket.udp_server_sockets(host, port)
    @debug   = debug
    @nodes   = []

    @sockets.each do |s|
      debug s.local_address, "server listening"
    end
  end

  def debug(addr = nil, string = nil)
    if @debug
      if addr && string
        puts "#{addr.inspect_sockaddr} #{string}"
      end

      @debug
    end
  end

  def poll
    Socket.udp_server_recv(IO.select(sockets)[0]) do |str, src|
      begin
        msg = JSON.parse(str)
        debug(src.remote_address, "read #{msg.inspect}")
        message_received(Hashie::Mash.new(msg))
      rescue JSON::JSONError
        debug(src.remote_address, "bad message: #{str.inspect}")
      end
    end

    sleep 0.1 if debug # slow things down a bit
  end

  def io_loop
    loop do
      poll
    end
  end

  def message_received(msg)
    case msg.type.intern
    when :node
      # store node info
    end
  end
end
