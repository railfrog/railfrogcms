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
          unless started?
            @installed_plugins = installed_plugins
            @registered_plugins = registered_plugins
            
            # unregister uninstalled plugins
            (@registered_plugins - @installed_plugins).each do |plugin|
              ::Plugin.find_by_name_and_version(*plugin).destroy
            end
            
            # initizalize @plugins (Plugin class takes care of registering unregistered plugins)
            @installed_plugins.each do |name_version|
              plugins << Plugin.new(name_version_to_spec_path(*name_version))
            end
            
            # start enabled plugins
            plugins.each do |plugin|
              plugin.start if plugin.enabled?
            end
            
            @started = true
            nil
          end
        end
        
        def shutdown
          plugins.clear
          @started = false
        end
        
        def started?
          @started ||= false
        end
        
        def plugins
          @plugins ||= []
        end
        
        def installed_plugins
          gems = Dir[File.join(root, "..", "specifications", "*.gemspec")]
          gems.select do |gem| 
            File.exist? File.join(root, File.basename(gem, ".gemspec"))
          end.map { |gem| File.basename(gem, ".gemspec").split(/-([^-]+)/) }
        end
        
        def registered_plugins
          plugins = ::Plugin.find_all
          plugins.map { |plugin| [plugin.name, plugin.version] }
        end
        
        def name_version_to_spec_path(name, version)
          File.join(root, "..", "specifications", "#{name}-#{version}.gemspec")
        end
      end
    end
  end
end

require 'plugin_system/plugin'
