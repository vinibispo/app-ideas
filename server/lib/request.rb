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
  end

  def self.parse(request)
    request_method, full_path, http_version = request.lines[0].split
    url, params = full_path.split('?')
    headers = {}
    body = request.split("\r\n\r\n", 2)[1]
    request.lines[1..].each do |line|
      header, value = line.split

      break if header.nil? || value.nil?

      headers[header.chop] = value
    end
    new(url:, params:, headers:, body:, request_method:, http_version:)
  end
end
