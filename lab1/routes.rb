require "net/http"
require "uri"
require "json"
require "thread/pool"
require "./convertor.rb"

class Tree
  @@array_jsons = Array.new

  def convert_data(body)
    converse = Convertor.new

    unless body["mime_type"].nil?

      if body["mime_type"].include? "csv"
        body["data"] = converse.csvToJson(body["data"])
      elsif body["mime_type"].include? "xml"
        body["data"] = converse.xmlToJson(body["data"])
      elsif body["mime_type"].include? "yaml"
        body["data"] = converse.yamlToJson(body["data"])
      end
    end

    return body["data"]
  end

  def traverse_tree(body)
    if body["link"].nil?
      @@array_jsons = converse_data(body["data"])
    else
      unless body["link"].is_a? String
        body["link"].values.each { |link_part|
          child_link_string = "#{@main_uri_string}#{link_part}"

          @pool = Thread.pool(10)
          @pool.process {
            child_link = URI(child_link_string)
            child_route = Net::HTTP::Get.new(child_link)
            child_route["X-Access-Token"] = get_token
            child_route_data = Net::HTTP.start(child_link.hostname, child_link.port) { |http|
              http.request(child_route)
            }
            if link_part.match("/route/3/3/2")
              child_route_data.body = child_route_data.body.gsub!("},]", "}]")
            end

            child_route_body = JSON.parse(child_route_data.body)

            child_route_body["data"] = convert_data(child_route_body)

            @@array_jsons.push(child_route_body["data"])

            traverse_tree(child_route_body)
          }
        }
      end
    end
  end

  def get_token
    # getting main data
    @main_uri_string = "http://localhost:5000"
    main_uri = URI(@main_uri_string)
    main_response = Net::HTTP.get_response(main_uri)
    main_body = JSON.parse(main_response.body)

    # reading register link
    register_part = main_body["register"]["link"]
    register_link_string = "#{@main_uri_string}#{register_part}"

    # getting token from register
    register_link = URI(register_link_string)
    register_route_response = Net::HTTP.get_response(register_link)
    @register_route_body = JSON.parse(register_route_response.body)
    token = @register_route_body["access_token"]
    return token
  end

  def get_home_body
    token = get_token
    # reading home link
    home_part = @register_route_body["link"]
    home_link_string = "#{@main_uri_string}#{home_part}"

    # getting data from home
    home_link = URI(home_link_string)
    home_route = Net::HTTP::Get.new(home_link)
    home_route["X-Access-Token"] = token
    home_route_data = Net::HTTP.start(home_link.hostname, home_link.port) { |http|
      http.request(home_route)
    }
    home_route_body = JSON.parse(home_route_data.body)
    traverse_tree(home_route_body)
    @pool.shutdown
  end

  def getJson
    return @@array_jsons
  end
end
