require "yaml"
require "active_support/core_ext/hash"

class Convertor
  def csvToJson(data)
    array = data.split("\n")
    keys = array[0].split(",")
    keys = keys.to_a
    array.delete array.first
    newList = array.map do |values|
      Hash[keys.zip(values.split(","))]
    end
    return JSON.pretty_generate(newList)
  end

  def xmlToJson(data)
    json = JSON.pretty_generate(Hash.from_xml(data))
    return json[:dataset][:record]
  end

  def yamlToJson(data)
    return JSON.pretty_generate(YAML.load(data))
  end
end
