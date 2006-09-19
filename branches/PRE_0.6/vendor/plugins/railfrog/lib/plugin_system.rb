require 'plugin_system/base'
require 'plugin_system/dependency_list'
require 'plugin_system/exceptions'
require 'plugin_system/plugin'
require 'plugin_system/plugins_list'
require 'plugin_system/rails_ext/action_view'
require 'plugin_system/rails_ext/action_controller'
require 'plugin_system/rails_ext/dependencies'

require 'plugin.rb'
unless Plugin.table_exists?
  load File.dirname(__FILE__) + '/../db/plugins_table.rb'
end

module PluginSystem
  Instance = Base.new(File.join(RAILS_ROOT, 'vendor', 'railfrog_plugins'))
end

#TODO: Install all .gem files in plugin system root that have not yet been installed
