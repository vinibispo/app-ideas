require 'net/http'
require 'uri'
require 'stringio'
require_relative '../lib/server'
require 'spec_helper'

RSpec.describe Server do
  before(:all) do
    @server = Server.new(StringIO.new)
    @mutex = Mutex.new
    @server_port = nil

    @server.listen(0) do |port|
      puts "Test server is running on port #{port}"
      @mutex.synchronize { @server_port = port }
    end

    @server.get('/hello') do |_req, res|
      res.status(:ok).send('Hello, World!')
    end

    @server.post('/hello') do |req, res|
      name = req.body['name']
      res.status(:created).send("Hello, #{name}!") unless name.nil?
      res.status(:bad_request).send('Name not provided') if name.nil?
    end

    @app_thread = Thread.new { @server.run }

    # Wait for the server to start
    sleep(0.1) until @mutex.synchronize { @server_port }
    @uri_base = "http://localhost:#{@mutex.synchronize { @server_port }}"
  end

  after(:all) do
    @mutex.synchronize do
      @server.stop
      # Allow some time for the server to stop
      sleep(0.1)
      @app_thread.join
    end
  end

  it 'responds to a GET request' do
    uri = URI("#{@uri_base}/hello")
    response = Net::HTTP.get(uri)
    expect(response).to match('Hello, World!')
  end

  it 'responds to a POST request' do
    uri = URI("#{@uri_base}/hello")
    name = 'Alice'
    response = Net::HTTP.post(uri, { name: name }.to_json, 'Content-Type' => 'application/json')

    expect(response.body).to match("Hello, #{name}!")
  end

  it 'responds with a 404 status code for an unknown route' do
    uri = URI("#{@uri_base}/unknown")
    response = Net::HTTP.get_response(uri)
    expect(response.code).to eq('404')
  end

  it 'responds with a 400 status code for a POST request with missing name' do
    uri = URI("#{@uri_base}/hello")
    response = Net::HTTP.post(uri, {}.to_json, 'Content-Type' => 'application/json')

    expect(response.code).to eq('400')
    expect(response.body).to match('Name not provided')
  end
end
