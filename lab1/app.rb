# file: app.rb
require "./readRoutes.rb"

class Application
  def main
    @tree = Tree.new
    @tree.get_home_body
  end

  def get_json
    return @tree.getJson
  end
end
