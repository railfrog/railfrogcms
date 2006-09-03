module RailFrog
  module PluginSystem
#    mattr_accessor :root
#    self.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "railfrog_plugins", "gems"))
  end
end

require 'railfrog/plugin_system/base'
require 'railfrog/plugin_system/plugin'
require 'railfrog/plugin_system/dependency_list'
