class Router
  def initialize(stdout = $stdout)
    @stdout = stdout
    @routes = {}
  end

  def get(path, &block)
    head(path, &block)
    add_route(:get, path, &block)
  end

  def post(path, &block)
    head(path, &block)
    add_route(:post, path, &block)
  end

  def put(path, &block)
    head(path, &block)
    add_route(:put, path, &block)
  end

  def delete(path, &block)
    head(path, &block)
    add_route(:delete, path, &block)
  end

  def patch(path, &block)
    head(path, &block)
    add_route(:patch, path, &block)
  end

  def head(path, &block)
    add_route(:head, path, &block)
  end

  def add_route(method, path, &block)
    @routes[method] ||= {}
    @routes[method][path] = block
  end

  def route(req, res)
    stdout.puts "#{req.request_method} #{req.url}"
    method = req.request_method.downcase.to_sym
    path = req.url
    return handle_not_found(res) unless @routes[method] && @routes[method][path]

    block = @routes[method][path]
    block.call(req, res)
  end

  def handle_not_found(res)
    res.status(:not_found)
    if File.exist?('public/404.html')
      res.render(html: 'public/404.html')
    else
      res.html('<h1>404 Not Found</h1>')
    end
  end
end
