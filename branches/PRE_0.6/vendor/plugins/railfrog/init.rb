require 'hash_extension'

if Dependencies.respond_to?(:autoloaded_constants) # I just try to figure out if Edge Rails is installed
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
end