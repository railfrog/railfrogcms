require 'hash_extension'

# The Plugin System needs Edge Rails to work. Set edge_rails = true if you have
# Edge Rails and want to start the Railfrog Plugin System.
# NOTE: Currently Rails Engines doesn't work with Edge Rails, so don't forget to
# turn Rails Engines off.
edge_rails = false

if edge_rails
  require 'plugin_system'
  require 'railfrog_resources'
  
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
