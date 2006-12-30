require 'hash_extension'
require 'plugin_system'

# FIXME: REMOVE THIS
if RAILS_ENV == 'test'
  PluginSystem::Instance.installed_plugins.each do |plugin|
    plugin.enable if plugin.disabled?
  end
end
####################

# Start Plugin System
PluginSystem::Instance.start(config)
