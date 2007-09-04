# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def partial_render(file, options = {})
    options[:string] = true
    return @controller.final_render(file, options)
  end
  
  def url_for_theme_resource(type, file, process_erb = false)
    build = process_erb ? 'true' : 'false'
    url_for :controller => '/theme', :action => 'resource', :theme => Theme::current, :resource => type, :filename => file, :build => build
  end
end
