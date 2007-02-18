module Railfrog::BaseHelper
  def nav_tab(controller_name, text)
    tab = "<a href=\"/railfrog/#{controller_name}\""
    tab += " class=\"active\"" if controller.controller_name == controller_name
    tab += ">#{text}</a>"
  end
end