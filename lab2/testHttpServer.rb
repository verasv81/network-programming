require "vihttp"
client_port = 1234
server_port = 12345

vihttpServer = VIHttpServer.new(server_port)
vihttpServer.connect(client_port)

loop do
  vihttpServer.get_command
end
