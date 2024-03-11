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
    @bind = 'localhost'
  end

  def listen(port, &block)
    @port = port
    block.call(port)
  end

  def start
    @server = TCPServer.new(@bind, @port)
    loop do
      accept do |client|
        req = Request.parse(client:)
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
    client = @server.accept
    block.call(client)
  end

  def close
    @server.close
  end

  alias stop close
end
