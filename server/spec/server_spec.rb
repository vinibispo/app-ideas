require 'net/http'
require 'uri'
require 'stringio'
require_relative '../lib/server'
require 'spec_helper'

RSpec.describe Server do
  before(:all) do
    @app = described_class.new

    @app.listen(3000) { |port| puts "Server listening on port #{port}" }

    @app.get '/hello' do |_req, res|
      res.send('Hello World')
    end

    @app.post '/hello' do |req, res|
      name = req.body['name']
      if name.nil? || name.empty?
        res.status(400).send('Name not provided')
      else
        res.send("Hello #{name}")
      end
    end
  end

  it 'should return Hello World' do
    @thread = Thread.new { @app.run }
    sleep 0.1

    client = TCPSocket.new('localhost', 3000)
    client.puts "GET /hello HTTP/1.1\r\n\r\n"
    response = client.read
    client.close

    expect(response).to match(/Hello World/)
    expect(response).to match(/200 OK/)

    @app.stop
    @thread.join
    sleep 0.1
  end

  it 'should return Hello John' do
    @thread = Thread.new { @app.run }
    sleep 0.1

    body = { name: 'John'}.to_json
    client = TCPSocket.new('localhost', 3000)
    client.puts "POST /hello HTTP/1.1\r\nContent-Length: #{body.bytesize}\r"
    client.puts"Content-Type: application/json\r\n\r\n"
    client.puts body
    response = client.read
    client.close

    expect(response).to match(/Hello John/)
    expect(response).to match(/200 OK/)

    @app.stop
    @thread.join
    sleep 0.1
  end

  it 'should return Name not provided' do
    @thread = Thread.new { @app.run }
    sleep 0.1

    body = { name: ''}.to_json
    client = TCPSocket.new('localhost', 3000)
    client.puts "POST /hello HTTP/1.1\r\nContent-Length: #{body.bytesize}\r"
    client.puts"Content-Type: application/json\r\n\r\n"
    client.puts body
    response = client.read
    client.close

    expect(response).to match(/Name not provided/)
    expect(response).to match(/400 Bad Request/)

    @app.stop
    @thread.join
    sleep 0.1
  end
end
