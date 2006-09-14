require 'hash_extension'

# The Plugin System needs Edge Rails to work. Set edge_rails = true if you have
# Edge Rails and want to start the Railfrog Plugin System.
# NOTE: Currently Rails Engines doesn't work with Edge Rails, so don't forget to
# turn Rails Engines off.
edge_rails = false

if edge_rails
  require 'plugin_system'

  # Start Plugin System 
  PluginSystem::Instance.start(config)
end
