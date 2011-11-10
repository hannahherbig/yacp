require 'json'
require 'rsa'
require 'bindata'

require 'logger'
require 'socket'

class Server
  attr_reader :server, :sockets, :logger

  def initialize(port, debug=false)
    @server  = TCPServer.new(port)
    @sockets = []
    @logger  = Logger.new($stdout)
    @debug   = debug

    debug "#{hostport(server.addr)} server listening"
  end

  def debug(string = nil)
    if @debug
      if string
        puts string
      end

      @debug
    end
  end

  def hostport(addr)
    "#{addr[2]}:#{addr[1]}"
  end

  def poll
    selections = IO.select(sockets + [server], nil, nil, nil)
    selections[0].each { |sock| readable(sock) }

    sleep 0.1 if debug # slow things down a bit
  end

  def readable(socket)
    if socket == server
      new_connection
    else
      begin
        readable_client(socket)
      rescue EOFError
        dead_client(socket)
      end
    end
  end

  def new_connection
    sock = server.accept
    sockets << sock
    debug "#{hostport(sock.addr)} new socket"
  end

  def readable_client(socket)
    debug "#{hostport(socket.addr)} readable"
    read = Hashie::Mash.new(JSON.parse(BinData::Stringz.read(socket).to_s))
    debug "#{hostport(socket.addr)} read: #{read.to_hash.inspect}"
  end

  def dead_client(socket)
    debug "#{hostport(socket.addr)} reached end of file"
    socket.close
    sockets.delete(socket)
  end

  def io_loop
    loop do
      poll
    end
  end
end
