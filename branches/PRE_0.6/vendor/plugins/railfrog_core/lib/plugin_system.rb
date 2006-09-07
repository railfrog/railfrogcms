module PluginSystem
  module Exceptions
    class Exception < ::Exception; end
  end
end

require 'plugin_system/base'
require 'plugin_system/plugin'
require 'plugin_system/dependency_list'
