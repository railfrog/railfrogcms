module PluginSystem
  class PluginsList
    include Enumerable
    
    attr_reader :dependency_order
    
    def initialize(*plugins)
      @plugins = []
      @dependency_order = []
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
    
    def clear
      @plugins.clear
      @dependency_order.clear
    end
    
    def [](full_name)
      self.find {|plugin| plugin.full_name == full_name }
    end
    
    def load_order
      dependency_order.reverse.select do |plugin|
        plugin.specification.dependencies.all? do |dep|
          self.any? { |p| p.specification.satisfies_requirement?(dep) }
        end
      end        
    end
    
    def generate_dependency_order
      @dependency_order = DependencyList.from_plugin_list(self).dependency_order.map do |spec|
        self[spec.full_name]
      end
    end
  end
  
  class DynamicPluginsList < PluginsList
    def initialize(plugins_list, filter)
      @plugins = plugins_list.entries
      @filter = filter
      @original_plugins_list = plugins_list
    end
    
    def each
      @plugins.each do |plugin|
        yield plugin if plugin.send @filter
      end
    end
    
    def dependency_order
      @original_plugins_list.dependency_order.select do |plugin| 
        plugin.send @filter
      end # Is this really OK???
    end
    
    private :add, :remove, :clear
  end
end
