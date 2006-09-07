require 'hash_extension'
require 'plugin_system'

require 'railfrog'

# start plugin system
PluginSystem::Base.startup(File.join(RAILS_ROOT, "vendor", "railfrog_plugins"))
