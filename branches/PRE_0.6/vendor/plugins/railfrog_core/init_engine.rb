require 'hash_extension'
require 'railfrog'
require 'plugin_system'

# start plugin system
PluginSystem::Base.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "railfrog_plugins"))
PluginSystem::Base.startup #unless RAILS_ENV == 'test'
