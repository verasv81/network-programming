require "./app.rb"
require "json"

class Search
  @@array = []

  def select_column(data, columnName)
    data = JSON.parse(data)
    if data.is_a?(Array)
      data.each do |json|
        unless json[columnName].nil?
          @@array.push(json[columnName])
        end
      end
    else
      push_if_not_null(data, columnName)
    end
    return not_empty_array
  end

  def select_from_column(data, columnName, pattern)
    reg = Regexp.new(pattern)

    data = JSON.parse(data)
    if data.is_a?(Array)
      data.each do |json|
        unless json[columnName].nil?
          value = json[columnName]
          if value.is_a?(Integer)
            value = value.to_s
            if value.match(reg)
              array.push(value)
            end
          else
            if value.match(reg)
              array.push(value)
            end
          end
        end
      end
    else
      push_if_not_null(data, columnName)
    end
    return not_empty_array
  end

  def is_array(data)
  end

  def not_empty_array
    unless @@array.empty?
      return @@array
    end
  end

  def push_if_not_null(data, columnName)
    unless data[columnName].nil?
      @@array.push(data[columnName])
    end
  end

  def clear
    @@array = []
  end
end
