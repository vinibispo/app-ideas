require 'socket'
require 'debug'
require_relative 'router'
require_relative 'request'
require_relative 'response'
class Server < Router
  def initialize
    super()
    @server = Socket.new(:INET, :STREAM)
  end

  def listen(port, &block)
    @server.bind(Socket.sockaddr_in(port, '127.0.0.1'))
    block.call(port)
    @server.listen(5)
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
end
