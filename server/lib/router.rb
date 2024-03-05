class Router
  def initialize
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
    method = req.request_method.downcase.to_sym
    path = req.url
    block = @routes[method][path]
    block.call(req, res)
  end
end
