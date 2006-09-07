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
    
    # Starts the plugin system. Set the root directory of the plugin system
    # (that is where the gems/ and specifications/ directory is located) with
    # the +root_dir+ parameter
    def self.startup(root_dir)
      base = self.new(root_dir)
      base.start
    end
    
    def initialize(root_dir)
      self.root = root_dir
      installed_plugins.each do |name_version|
        plugins[name_version] = Plugin.new(File.join(@path_to_specs, "#{name_version.join('-')}.gemspec"))
      end
    end
    
    def start
      unless (@started ||= false)
        # start enabled plugins
        @enabled_plugins = plugins.values.select { |plugin| plugin.enabled? }
        DependencyList.from_plugin_list(@enabled_plugins).dependency_order.reverse.each do |spec|
          # only start plugins which dependencies are met
          plugins(spec.name, spec.version.to_s).start if spec.dependencies.all? do |dep|
            @enabled_plugins.any? { |p| p.specification.satisfies_requirement?(dep) }
          end
        end
        @started = true
      end
    end
    
    def shutdown
      if (@started ||= false)
        @enabled_plugins.each { |plugin| plugin.stop if plugin.started? }
        @started = false
      end
    end
    
    def plugins(name=nil, version=nil)
      #TODO: Add specs for this method
      if name.nil? && version.nil?
        @plugins ||= {}
      elsif name.kind_of?(String) && version.kind_of?(String)
        @plugins[[name, version]]
      end
    end
    
    def installed_plugins
      gems = Dir[File.join(@path_to_specs, "*.gemspec")]
      gems.select do |gem| 
        File.exist? File.join(@path_to_gems, File.basename(gem, ".gemspec"))
      end.map { |gem| File.basename(gem, ".gemspec").split(/-([^-]+)/) }
    end
    
    private
    
    def root=(value)
      @root = File.expand_path(value)
      @path_to_gems = File.join(@root, 'gems')
      @path_to_specs = File.join(@root, 'specifications')
    end    
  end
end
