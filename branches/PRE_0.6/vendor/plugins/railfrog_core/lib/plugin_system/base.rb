module PluginSystem
  class Base
    cattr_accessor :root 
    cattr_reader :path_to_gems, :path_to_specs
    
    class << self
      def root=(value)
        @@root = File.expand_path(value)
        @@path_to_gems = File.join(self.root, 'gems')
        @@path_to_specs = File.join(self.root, 'specifications')
      end
      
      def init
        unless initialized?
          installed_plugins.each do |name_version|
            plugins[name_version] = Plugin.new(File.join(path_to_specs, "#{name_version.join('-')}.gemspec"))
          end
          @initialized = true
        end
      end
      
      def startup
        init
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
        end
      end
      
      #TODO: stop plugins
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
        gems = Dir[File.join(@@path_to_specs, "*.gemspec")]
        gems.select do |gem| 
          File.exist? File.join(@@path_to_gems, File.basename(gem, ".gemspec"))
        end.map { |gem| File.basename(gem, ".gemspec").split(/-([^-]+)/) }
      end
    end
  end
end
