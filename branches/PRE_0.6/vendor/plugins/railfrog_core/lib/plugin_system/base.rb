module RailFrog
  class Exception < Exception
  end
end

module RailFrog
  module PluginSystem
    class Base
      @@root_directory = File.expand_path(File.join(RAILS_ROOT, "vendor", "railfrog_plugins", "gems"))
      
      def self.root
        @@root_directory
      end
      
      def self.root=(path)
        @@root_directory = path
      end
    end
  end
end

require 'plugin_system/plugin'
