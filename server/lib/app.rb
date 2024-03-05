require_relative 'server'

app = Server.new
app.listen(3000) do |port|
  puts "Server is running on port #{port}"
end

app.get('/hello') do |_req, res|
  res.status(:ok).send('Hello, World!')
end

app.post('/hello') do |req, res|
  puts req.body
  res.status(:created).send('Hello, World!')
end

app.run
