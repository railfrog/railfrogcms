module RailFrog
  class Exception < Exception
  end
end

module RailFrog
  module PluginSystem
    class Base
      cattr_accessor :root
      self.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "railfrog_plugins", "gems"))
      
      class << self        
        def startup          
          # unregister uninstalled plugins
          (registered_plugins - installed_plugins).each do |plugin|
            ::Plugin.find_by_name_and_version(*plugin).destroy
          end
          
          # initizalize @plugins (Plugin class takes care of registering unregistered plugins)
          Dir[File.join(root, "..", "specifications", "*.gemspec")].each do |gemspec|
            plugins << Plugin.new(gemspec)
          end
          
          # start enabled plugins
          plugins.each do |plugin|
            plugin.start if plugin.enabled?
          end
          
          nil
        end
        
        def shutdown
          @plugins.clear unless @plugins == nil
        end
        
        def plugins
          @plugins ||= Array.new
        end
        
        def installed_plugins
          gems = Dir[File.join(root, "..", "specifications", "*.gemspec")]
          gems.select do |gem| 
            File.exist? File.join(root, File.basename(gem, ".gemspec"))
          end.map {|gem| File.basename(gem, ".gemspec").split(/-([^-]+)/)}
        end
        
        def registered_plugins
          plugins = ::Plugin.find_all
          plugins.map {|plugin| [plugin.name, plugin.version]}
        end
      end
    end
  end
end

require 'plugin_system/plugin'
