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

    @sockets.each do |s|
      debug "#{s.local_address.inspect_sockaddr} server listening"
    end
  end

  def debug(string = nil)
    if @debug
      if string
        puts string
      end

      @debug
    end
  end

  def poll
    Socket.udp_server_recv(IO.select(sockets)[0]) do |str, src|
      msg = Hashie::Mash.new(JSON.parse(str))
      debug("#{src.remote_address.inspect_sockaddr} read #{msg.to_hash.inspect}")
    end

    sleep 0.1 if debug # slow things down a bit
  end

  def io_loop
    loop do
      poll
    end
  end
end
