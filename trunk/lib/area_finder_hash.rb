class AreaFinderHash < Hash
  attr_reader :areas
  HTML_DIV_FORMAT = "<div id='area-%s' style='border: 1px solid %s;background-color: %s;text-align: center;vertical-align: middle;padding: %s;color: %s;font-family:verdana,arial,sans-serif;'>%s</div>"
  
  def initialize
    super
    @areas = []
    @border_color = '#00688B'
    @background_color = '#ADEAEA'
    @padding = '50px'
    @font_color = '#00688B'
  end
  
  def [](area_name, options = {})
    if @areas.detect { |a| a == area_name }.nil?      
      @areas.push(area_name)
      
      border_color = options[:border_color].nil? ? @border_color : options[:border_color]
      background_color = options[:background_color].nil? ? @background_color : options[:background_color]
      padding = options[:padding].nil? ? @padding : options[:padding]
      font_color = options[:font_color].nil? ? @font_color : options[:font_color]
      return sprintf(HTML_DIV_FORMAT, area_name, border_color, background_color, padding, font_color, area_name)
    end
  end
end