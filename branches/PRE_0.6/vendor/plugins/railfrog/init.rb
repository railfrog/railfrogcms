require 'hash_extension'
require 'plugin_system'
require File.join(RAILS_ROOT, 'vendor', 'plugins', 'railfrog', 'app', 'models', 'plugin.rb')

unless Plugin.table_exists?
  load File.dirname(__FILE__) + '/db/plugins_table.rb'
end

rf_plugins_root = File.join(RAILS_ROOT, 'vendor', 'railfrog_plugins')
PluginSystem::Base.startup(rf_plugins_root)