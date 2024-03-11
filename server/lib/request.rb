class Request
  attr_reader :url, :params, :headers, :body, :request_method, :http_version

  def initialize(**args)
    url, params, headers, body, request_method, http_version = args.values_at(
      :url,
      :params,
      :headers,
      :body,
      :request_method,
      :http_version
    )

    @url = url
    @params = params
    @headers = headers
    @body = body
    @request_method = request_method
    @http_version = http_version

    return unless (json? || form_urlencoded?) && body && !body.empty?

    @body = JSON.parse(body)
  rescue JSON::ParserError
    @body = body
  end

  def json?
    headers['Content-Type'] == 'application/json'
  end

  def form_urlencoded?
    headers['Content-Type'] == 'application/x-www-form-urlencoded'
  end

  def self.parse(client:)
    request_method, full_path, http_version = client.gets.gsub("\r\n", '').split(' ')

    url, params = extract_url_and_params(full_path)
    headers = extract_headers(client)
    body = client.read(headers['Content-Length'].to_i)
    new(url:, params:, headers:, body:, request_method:, http_version:)
  end

  class << self
    private

    def extract_url_and_params(full_path)
      url, params = full_path.split('?')

      return url, {} unless params

      params = params.split('&').map do |param|
        key, value = param.split('=')
        [key, value]
      end.to_h
      [url, params]
    end

    def extract_headers(client)
      headers = {}
      loop do
        line = client.gets
        break if line == "\r\n"

        key, value = line.gsub("\r\n", '').split(': ')
        headers[key.strip] = value.strip
      end
      headers
    end
  end
end
