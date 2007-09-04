require_dependency 'core_ext/object.rb'
require_dependency 'plugin_api/base.rb'

if Plugin.table_exists?
  RailFrogPluginAPI::setup
  RailFrogPluginAPI::start_enabled
end