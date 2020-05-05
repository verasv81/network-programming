require "socket"
require "./app.rb"
require "./search.rb"
require "json"

search = Search.new

server = TCPServer.new 2000
app = Application.new
app.main
$json_array = app.get_json

$pool = Thread.pool(10)
$pool.process {
  loop do
    client = server.accept
    client.print "Write select:\n-> selectColumn column_name or \n-> selectFromColumn column_name pattern\n"
    command = client.gets.strip
    command_array = command.split(" ")
    column = command_array[1]

    if command_array[0].match("selectColumn")
      $json_array.each do |json|
        searchArray = search.selectColumn(json, column)
        unless searchArray.nil?
          client.print searchArray
          client.print "\n\n"
        end
      end
    else
      pattern = command_array[2]
      $json_array.each do |json|
        searchArray = search.selectFromColumn(json, column, pattern)
        unless searchArray.nil?
          client.print searchArray
          client.print "\n\n"
        end
      end
    end
    client.close
  end
}

$pool.shutdown
