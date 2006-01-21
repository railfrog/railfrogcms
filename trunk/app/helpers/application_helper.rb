# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def partial_render(file, options = {})
    options[:string] = true
    return @controller.final_render(file, options)
  end
end
