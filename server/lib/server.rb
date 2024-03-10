require 'socket'
require 'debug'
require_relative 'router'
require_relative 'request'
require_relative 'response'
class Server < Router
  attr_reader :stdout

  def initialize(stdout = $stdout)
    super(stdout)
    @server = Socket.new(:INET, :STREAM)
    @stdout = stdout
  end

  def listen(port, &block)
    addr = Socket.pack_sockaddr_in(port, '127.0.0.1')

    @server.bind(addr)

    @server.listen(5)
    actual_port = Socket.unpack_sockaddr_in(@server.getsockname).first

    block.call(actual_port)

    actual_port
  end

  def start
    loop do
      accept do |client|
        request = client.recv(1000)

        req = Request.parse(request)
        res = Response.new(client:, http_version: req.http_version)
        route(req, res)
        client.close
      end
    rescue IOError
      stdout.puts 'Server is shutting down...'
      break
    end
  end

  alias run start

  def accept(&block)
    client, = @server.accept
    block.call(client)
  end

  def close
    @server.close
  end

  alias stop close
end
