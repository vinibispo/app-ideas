require 'json'
require 'erb'
require 'stringio'
class Response
  attr_reader :client, :http_version

  SYMBOLS_TO_STATUS = {
    ok: '200 OK',
    not_found: '404 Not Found',
    internal_server_error: '500 Internal Server Error',
    created: '201 Created',
    no_content: '204 No Content',
    moved_permanently: '301 Moved Permanently',
    found: '302 Found',
    see_other: '303 See Other',
    bad_request: '400 Bad Request',
    unauthorized: '401 Unauthorized',
    forbidden: '403 Forbidden',
    conflict: '409 Conflict',
    gone: '410 Gone',
    unprocessable_entity: '422 Unprocessable Entity',
    too_many_requests: '429 Too Many Requests'
  }.freeze

  NUMBERS_TO_STATUS = {
    200 => '200 OK',
    404 => '404 Not Found',
    500 => '500 Internal Server Error',
    201 => '201 Created',
    204 => '204 No Content',
    301 => '301 Moved Permanently',
    302 => '302 Found',
    303 => '303 See Other',
    400 => '400 Bad Request',
    401 => '401 Unauthorized',
    403 => '403 Forbidden',
    409 => '409 Conflict',
    410 => '410 Gone',
    422 => '422 Unprocessable Entity',
    429 => '429 Too Many Requests'
  }.freeze

  def initialize(client:, http_version: 'HTTP/1.1')
    @client = client
    @status = '200 OK'
    @headers = {}
    @body = ''
    @http_version = http_version
  end

  def set(header, value)
    @headers[header] = value
    self
  end

  def location(url)
    @headers['Location'] = url
    self
  end

  def redirect(url, status = :found)
    status(status).location(url).send('')
  end

  def get(header)
    @headers[header]
  end

  def status(code)
    @status = if code.is_a?(Symbol)
                SYMBOLS_TO_STATUS[code]
              else
                NUMBERS_TO_STATUS[code]
              end
    self
  end

  def send(body)
    @body = body
    send_response
  end

  def html(body)
    @headers['Content-Type'] = 'text/html'
    @body = body
    send_response
  end

  def json(data)
    @headers['Content-Type'] = 'application/json'
    @body = data.to_json
    send_response
  end

  def render(**args)
    @body = if args[:template]
              ERB.new(File.read(args[:template])).result(binding)
            elsif args[:html]
              File.read(args[:html])
            elsif args[:json]
              args[:json].to_json
            else
              args
            end
    send_response
  end

  def send_response
    client.puts "#{http_version} #{@status}"
    @headers.each { |header, value| client.puts "#{header}: #{value}" }
    client.puts
    client.puts @body
  end
end
