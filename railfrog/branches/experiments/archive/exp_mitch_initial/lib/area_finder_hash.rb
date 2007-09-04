class AreaHash
  attr_reader :areas
  HTML_DIV_FORMAT = "<div id='area-%s' class='area'>%s</div>"
  
  def initialize
    super
    @areas = {}
  end
  
  def [](area_name, options = {})
    if @areas[area_name].nil?      
      @areas[area_name] = ''

      return sprintf(HTML_DIV_FORMAT, area_name, area_name)
    else
      return @areas[area_name]
    end
  end
end