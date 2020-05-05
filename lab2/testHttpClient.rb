require "vihttp"

vihttpClient = VIHttpClient.new(1234)
vihttpClient.connect(12345)

loop do
  puts "-------------------------------------"
  puts "Enter a command:"
  puts "--> add <key> <value>"
  puts "--> update <key> <newvalue>"
  puts "--> remove <key>"
  puts "--> get"
  puts "--> clear"
  puts "-------------------------------------"
  command = gets.chomp
  command_array = command.split(" ")
  if command_array[0].match("add")
    data = "key=>" + command_array[1] + ";value=>" + command_array[2]
    vihttpClient.send_command(command_array[0], data)
  elsif command_array[0].match("update")
    data = "key=>" + command_array[1] + ";newValue=>" + command_array[2]
    vihttpClient.send_command(command_array[0], data)
  elsif command_array[0].match("remove")
    vihttpClient.send_command(command_array[0], command_array[1])
  elsif command_array[0].match("get")
    puts "-------------------------------------"
    vihttpClient.send_command(command_array[0], "empty")
    puts vihttpClient.get_dictionary
    puts "-------------------------------------"
  elsif command_array[0].match("clear")
    vihttpClient.send_command(command_array[0], "empty")
  else
    puts "command not found"
  end
end
