module PluginSystem
  class Base
    # Path to the root directory of the plugin system instance. That's the
    # directory which contains the 'gems' and 'specifications' directories.
    attr_reader :root
    
    # Path to the 'gems' directory of the plugin system so that you don't have
    # to use File.join(root, 'gems').
    # The gems directory contains the installed plugins.
    attr_reader :path_to_gems

    # Path to the 'specifications' directory of the plugin system so that you
    # don't have to use File.join(root, 'specifications').
    # The specifications directory contains the specification files for the
    # installed plugins.
    attr_reader :path_to_specs
    
    #
    attr_reader :installed_plugins
    
    #
    attr_reader :enabled_plugins
    
    #
    attr_reader :started_plugins
    
    # Set the +root_dir+ parameter to the root directory of your plugin system.
    def initialize(root_dir)
      self.root = root_dir
      @started = false
      
      plugins = Dir[File.join(path_to_specs, "*.gemspec")].map {|file| Plugin.new(file) }
      @installed_plugins = PluginsList.new(*plugins)
      @enabled_plugins   = DynamicPluginsList.new(installed_plugins, :enabled?)
      @started_plugins   = DynamicPluginsList.new(installed_plugins, :started?)
      
      registered_plugins.each do |plugin| 
        plugin.destroy if installed_plugins[plugin.full_name].nil?
      end
    end
    
    #
    #
    def start(config=nil)
      unless @started
        enabled_plugins.load_order.each {|plugin| plugin.start(config) }
        @started = true
      end
    end
    
    #
    #
    def shutdown
      if @started
        started_plugins.load_order.reverse.each {|plugin| plugin.stop }
        @started = false
      end
    end
    
#    def reload
#      installed_plugins.clear
#      plugins = Dir[File.join(path_to_specs, "*.gemspec")].map {|file| Plugin.new(file) }
#      installed_plugins.add(*plugins)
#      
#      registered_plugins.each do |plugin| 
#        plugin.destroy if installed_plugins[plugin.full_name].nil?
#      end
#    end
    
    #
    #
    def registered_plugins
      Database::Plugin.find(:all)
    end
    
    private
      def root=(value)
        @root = File.expand_path(value)
        @path_to_gems = File.join(@root, 'gems')
        @path_to_specs = File.join(@root, 'specifications')
      end
  end
end
