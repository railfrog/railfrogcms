require 'hash_extension'

# The Plugin System needs Edge Rails to work. Set edge_rails = true if you have
# Edge Rails and want to start the Railfrog Plugin System.
# NOTE: Currently Rails Engines doesn't work with Edge Rails, so don't forget to
# turn Rails Engines off.
edge_rails = false

if edge_rails
  require 'plugin_system'
  require File.join(RAILS_ROOT, 'vendor', 'plugins', 'railfrog', 'app', 'models', 'plugin.rb')
  
  unless Plugin.table_exists?
    load File.dirname(__FILE__) + '/db/plugins_table.rb'
  end

  # Start Plugin System 
  rf_plugins_root = File.join(RAILS_ROOT, 'vendor', 'railfrog_plugins')
  PluginSystem::Base.startup(rf_plugins_root, config)
end
