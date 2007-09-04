%w{base
   dependency_list
   exceptions
   plugin
   plugins_list
   database/plugin
  }.each do |f|
  require "plugin_system/#{f}"
end
