require 'plugin_system/base'
require 'plugin_system/exceptions'
require 'plugin_system/plugin'
require 'plugin_system/dependency_list'
require 'plugin_system/rails_ext/action_view_extensions'
require 'plugin_system/rails_ext/action_controller_extensions'

require 'plugin.rb'
unless Plugin.table_exists?
  load File.dirname(__FILE__) + '/../db/plugins_table.rb'
end

module PluginSystem
  Instance = Base.new(File.join(RAILS_ROOT, 'vendor', 'railfrog_plugins'))
end

