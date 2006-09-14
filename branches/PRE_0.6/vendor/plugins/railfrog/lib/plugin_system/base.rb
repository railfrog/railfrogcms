module PluginSystem
  class Base
    # Path to the directory which contains the gems/ and specifications/ 
    # directories
    attr_reader :root
    
    # Path to the directory which contains the installed plugins
    attr_reader :path_to_gems
    
    # Path to the directory which contains the specification files of the 
    # installed plugins 
    attr_reader :path_to_specs
    
    attr_reader :installed_plugins,
                :enabled_plugins,
                :disabled_plugins,
                :started_plugins
    
    def initialize(root_dir)
      self.root = root_dir
      
      plugins = Dir[File.join(path_to_specs, "*.gemspec")].map {|file| Plugin.new(file)}
      @installed_plugins = Plugins.new(*plugins)
      @enabled_plugins   = Plugins.new(*plugins.select {|plugin| plugin.enabled?  })
      @disabled_plugins  = Plugins.new(*plugins.select {|plugin| plugin.disabled? })
      @started_plugins   = Plugins.new(*plugins.select {|plugin| plugin.started?  })
      
      ::Plugin.find(:all).each do |plugin| 
        plugin.destroy if @installed_plugins[plugin.full_name].nil?        
      end
    end
    
    def start(config=nil)
      unless (@started ||= false)
        # start enabled plugins
        @enabled_plugins.load_order.each { |plugin| plugin.start(config) }
        @started = true
      end
    end
    
    def shutdown
      if (@started ||= false)
        @enabled_plugins.each { |plugin| plugin.stop if plugin.started? }
        @started = false
      end
    end
    
    def registered_plugins
      ::Plugin.find(:all)
    end
    
    #TODO: The *_plugin methods should take care of dependencies
    
    def enable_plugin(full_name)
      if plugin = @disabled_plugins[full_name]
        plugin.enable
        @disabled_plugins.remove(plugin)
        @enabled_plugins.add(plugin)
      else
        raise
      end
    end
    
    def disable_plugin(full_name)
      if plugin = @enabled_plugins[full_name]
        plugin.disable
        @enabled_plugins.remove(plugin)
        @disabled_plugins.add(plugin)
      else
        raise
      end
    end
    
    def start_plugin(full_name)
      if plugin = @enabled_plugins[full_name]
        plugin.start
        @started_plugins.add(plugin)
      else
        raise
      end
    end

    def stop_plugin(full_name)
      if plugin = @started_plugins[full_name]
        plugin.stop
        @started_plugins.remove(plugin)
      else
      end
    end
    
    class Plugins
      include Enumerable
      
      attr_reader :dependency_list
      
      def initialize(*plugins)
        @plugins = []
        add(*plugins)
      end
      
      def each
        @plugins.each do |plugin|
          yield plugin
        end
      end
      
      def add(*plugins)
        @plugins.concat plugins
        generate_dependency_order
      end
      
      def remove(plugin)
        @plugins.delete plugin
        generate_dependency_order
      end
      
      def [](full_name)
        @plugins.find {|plugin| plugin.full_name == full_name }
      end
      
      def load_order
        @dependency_order.reverse.select do |plugin|
          plugin.specification.dependencies.all? do |dep|
            @plugins.any? { |p| p.specification.satisfies_requirement?(dep) }
          end
        end        
      end
      
      private
        def generate_dependency_order
          @dependency_order = ::PluginSystem::DependencyList.from_plugin_list(@plugins).dependency_order.map do |spec|
            self[spec.full_name]
          end
        end
    end
    
    private
      def root=(value)
        @root = File.expand_path(value)
        @path_to_gems = File.join(@root, 'gems')
        @path_to_specs = File.join(@root, 'specifications')
      end
  end
end
