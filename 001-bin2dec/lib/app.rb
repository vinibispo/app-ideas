require_relative '../../server/lib/server'
app = Server.new
app.listen(3000) do |port|
  puts "Server is listening on port #{port}"
end

app.get('/') do |_req, res|
  res.render(html: 'public/index.html')
end

app.post('/bin2dec') do |req, res|
  binary = req.body['binary']
  decimal = binary.to_i(2)
  res.json({ decimal: })
end

app.run

Signal.trap('INT') { app.stop }
Signal.trap('TERM') { app.stop }
