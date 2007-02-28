%w{action_controller
   action_view
   active_record
   dependencies
   routing
  }.each do |f|
  require "plugin_system/rails_ext/#{f}"
end
