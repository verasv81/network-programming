require "net/http"
require "viudp"

class VIHttpClient
  def initialize(client_port)
    @client_port = client_port
    @pair = Hash.new("Client hash")
  end

  def connect(server_port)
    @server_port = server_port
    @viudpClient = VIudp.new(@client_port)
    @viudpClient.connect(@server_port)
  end

  def get_dictionary
    return @viudpClient.receive
  end

  def send_command(command, data)
    @pair.clear
    @pair[command] = data
    @viudpClient.send(@pair.to_s)
  end
end

class VIHttpServer
  def initialize(server_port)
    @server_port = server_port
    @dictionary = Hash.new("Dictionary")
  end

  def connect(client_port)
    @client_port = client_port
    @viudpServer = VIudp.new(@server_port)

    @viudpServer.acceptConnection(@client_port)
  end

  def get_command
    command = @viudpServer.receive

    result = eval(command)

    if result.has_key?("add")
      add(result["add"])
    elsif result.has_key?("update")
      update(result["update"])
    elsif result.has_key?("remove")
      remove(result["remove"])
    elsif result.has_key?("clear")
      @dictionary = @dictionary.clear
    elsif result.has_key?("get")
      puts @dictionary
      if @dictionary.empty?
        @viudpServer.send("Empty dictionary")
      else
        @viudpServer.send(@dictionary.to_s)
      end
    end
  end

  private

  def add(value)
    key_value = value.split(";")
    key_value[0].gsub!("key=>", "")
    key_value[1].gsub!("value=>", "")
    @dictionary[key_value[0]] = key_value[1]
  end

  def update(value)
    key_value = value.split(";")
    key_value[0].gsub!("key=>", "")
    key_value[1].gsub!("newValue=>", "")
    @dictionary[key_value[0]] = key_value[1]
  end

  def remove(key)
    if @dictionary.has_key?(key)
      @dictionary.delete(key)
    end
  end
end
