require 'hash_extension'
require 'plugin_system'
require File.join(RAILS_ROOT, 'vendor', 'plugins', 'railfrog', 'app', 'models', 'plugin.rb')

# Start Plugin System
rf_plugins_root = File.join(RAILS_ROOT, 'vendor', 'railfrog_plugins')
#PluginSystem::Base.startup(config, rf_plugins_root)
PluginSystem::Base.startup(rf_plugins_root)

# Add Railfrog Controllers to controller_path
#config.controller_paths.concat [File.join(RAILS_ROOT, 'vendor', 'plugins', 'railfrog_core', 'app', 'controllers')]

# Do stuff...
#require 'rf_experiments'
