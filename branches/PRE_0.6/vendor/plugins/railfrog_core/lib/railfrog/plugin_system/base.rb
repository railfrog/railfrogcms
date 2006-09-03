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
        def init
          unless initialized?
            inst_plugins = installed_plugins
            reg_plugins = registered_plugins
            
            # unregister uninstalled plugins
            (reg_plugins - inst_plugins).each do |name_version|
              ::Plugin.find_by_name_and_version(*name_version).destroy
            end
            
            # initizalize @plugins (Plugin class takes care of registering unregistered plugins)
            inst_plugins.each do |name_version|
              plugins[name_version] = Plugin.new(File.join(root, "..", "specifications", "#{name_version.join('-')}.gemspec"))
            end
            
            @initialized = true
          end
        end
        
        def startup
          init unless initialized?
          unless started?            
            # start enabled plugins
            enabled_plugins = plugins.values.select { |plugin| plugin.enabled? }
            DependencyList.from_plugin_list(enabled_plugins).dependency_order.reverse.each do |spec|
              # only start plugins which dependencies are met
              plugins(spec.name, spec.version.to_s).start if spec.dependencies.all? do |dep|
                enabled_plugins.find { |p| p.specification.satisfies_requirement?(dep) }
              end
            end
            @started = true
            nil
          end
        end
        
        def shutdown
          plugins.clear
          @started = false
          @initialized = false
        end
        
        def initialized?
          @initialized ||= false
        end
        
        def started?
          @started ||= false
        end
        
        def plugins(name=nil, version=nil)
          #TODO: Add specs for this method
          if name.nil? && version.nil?
            @plugins ||= {}
          elsif name.kind_of?(String) && version.kind_of?(String)
            @plugins[[name, version]]
          else
            raise SyntaxError
          end
        end
        
        def installed_plugins
          gems = Dir[File.join(root, "..", "specifications", "*.gemspec")]
          gems.select do |gem| 
            File.exist? File.join(root, File.basename(gem, ".gemspec"))
          end.map { |gem| File.basename(gem, ".gemspec").split(/-([^-]+)/) }
        end
        
        def registered_plugins
          plugins = ::Plugin.find(:all)
          plugins.map { |plugin| [plugin.name, plugin.version] }
        end
      end
    end
  end
end
