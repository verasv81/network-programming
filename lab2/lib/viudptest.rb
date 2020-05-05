require "socket"
require "base64"
require "encryption"
require "digest"

BUFFER_SIZE = 1000

class VIudp
  def initialize(sender_port)
    @sender_port = sender_port
  end

  def connect(receiver_port)
    @receiver_port = receiver_port
    @sender = UDPSocket.new
    @sender.bind("localhost", @sender_port)
    # first handshake
    @sender.send("Connecting...", 0, "localhost", @receiver_port)
    # second handashake receiving RSA public key
    public_RSA_key, sender = @sender.recvfrom(BUFFER_SIZE)
    rsa_public_key = OpenSSL::PKey::RSA.new(public_RSA_key)
    #third handshake sending encrypted AES key
    @aes_key = generate_random_string(32) #generating AES key
    encrypted_aes_key = Base64.encode64(rsa_public_key.public_encrypt(@aes_key)) #encrypt AES key with RSA public key
    @sender.send(encrypted_aes_key, 0, "localhost", @receiver_port)
    #fourth handashake receiving confirmation
    confirmation_msg, sender = @sender.recvfrom(BUFFER_SIZE)
    # puts confirmation_msg #if ok continue, if not break
  end

  def acceptConnection(receiver_port)
    @receiver_port = receiver_port
    @sender = UDPSocket.new
    @sender.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1)
    @sender.bind("localhost", @sender_port)
    @clientPorts = []

    connection_msg, sender = @sender.recvfrom(BUFFER_SIZE)

    Thread.new(sender) do |clientAddress|
      puts "New client has joined"
      unless @clientPorts.include? @receiver_port
        @clientPorts << @receiver_port
      end
      @clientPorts.each do |client|
        puts "HI"
        if (connection_msg.include? "Connecting")
          public_RSA_key, private_RSA_key = Encryption::Keypair.generate(2048)
          #second handshake sending the RSA public key
          @sender.send(public_RSA_key.to_s, 0, "localhost", client)
          #third handshake receiving encrypted AES key and decrypt it using private RSA key
          encrypted_aes_key, sender = @sender.recvfrom(BUFFER_SIZE)
          @aes_key = private_RSA_key.decrypt(Base64.decode64(encrypted_aes_key))
          #fourth handashake sending that the key was received
          @sender.send("The key was received...", 0, "localhost", client)
        else puts "Didn't receive any connection request"         end
      end
    end
  end

  def send(message)
    sending(@sender, @receiver_port, message, @aes_key)
    confirmation_message = receiving(@sender, @aes_key)
    if (confirmation_message.include? "Retransmit")
      send(@receiver_port, message)
    end
  end

  def receive
    confirmation_msg = receiving(@sender, @aes_key)
    sending(@sender, @receiver_port, confirmation_msg, @aes_key)
    puts "Confirmation: " + confirmation_message
    return confirmation_msg
  end
end

private

def sending(sender, destination_port, message, key)
  final_message = encryption(key, message) + "hash:" + hash_creation(message)
  sender.send(final_message, 0, "localhost", destination_port)
end

def encryption(key, message)
  cipher = OpenSSL::Cipher::AES256.new :CBC
  cipher.encrypt
  cipher.key = key
  encrypted_message = cipher.update(message) + cipher.final
  return encrypted_message
end

def hash_creation(message)
  hash = Digest::SHA256.hexdigest(message)
  return hash
end

def decryption(key, message)
  decipher = OpenSSL::Cipher::AES256.new :CBC
  decipher.decrypt
  decipher.key = key
  decrypted_message = decipher.update(message) + decipher.final
  return decrypted_message
end

def receiving(receiver, key)
  initial_message, sender = receiver.recvfrom(BUFFER_SIZE)
  initial_message = initial_message.split("hash:")
  encrypted_message = initial_message[0]
  initial_hash = initial_message[1]
  decrypted_message = decryption(key, encrypted_message)
  if (initial_hash == hash_creation(decrypted_message))
    return decrypted_message
  else
    return "Retransmit"
  end
end

def generate_random_string(length)
  string = ""
  chars = ("A".."Z").to_a
  length.times do
    string << chars[rand(chars.length - 1)]
  end
  return string
end
