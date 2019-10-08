require "./app.rb"
require "JSON"

class Search
  def selectColumn(data, columnName)
    array = []

    data = JSON.parse(data)
    if data.is_a?(Array)
      data.each do |json|
        unless json[columnName].nil?
          array.push(json[columnName])
        end
      end
    else
      unless data[columnName].nil?
        array.push(data[columnName])
      end
    end
    unless array.empty?
      return array
    end
  end

  def selectFromColumn(data, columnName, pattern)
    array = []

    data = JSON.parse(data)

    reg = Regexp.new(pattern)
    if data.is_a?(Array)
      data.each do |json|
        unless json[columnName].nil?
          value = json[columnName]
          if value.match(reg)
            array.push(value)
          end
        end
      end
    else
      unless data[columnName].nil?
        array.push(data[columnName])
      end
    end
    unless array.empty?
      return array
    end
  end
end
