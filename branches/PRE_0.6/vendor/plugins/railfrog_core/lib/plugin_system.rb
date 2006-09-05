module PluginSystem
#    mattr_accessor :root
#    self.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "railfrog_plugins", "gems"))
  class Exception < ::Exception; end    
end

require 'plugin_system/base'
require 'plugin_system/plugin'
require 'plugin_system/dependency_list'
