module ::ActionController
  class Base
    unless defined? @@additional_template_roots
      @@additional_template_roots = []
    end
    
    def self.additional_template_roots
      @@additional_template_roots = ::PluginSystem::Instance.started_plugins.load_order.reverse.inject([]) do |array, plugin|
        plugin_template_root = File.join(plugin.path_to_gem, 'app', 'views')
        array << plugin_template_root if File.exist?(plugin_template_root)
        array
      end
    end
    
    def additional_template_roots
      self.class.additional_template_roots
    end
  end
  
  module Layout
    module ClassMethods
      private
        alias :railfrog_original_layout_list :layout_list
        def layout_list
          additional_template_roots.inject(railfrog_original_layout_list) do |array, tmpl_root|
            array.concat Dir.glob("#{tmpl_root}/layouts/**/*")
          end
        end
    end
  end
  
  module Routing
    class RouteSet
      def add_maps
        yield Mapper.new(self)
        named_routes.install
      end
      
      def load_routes!
        load File.join("#{RAILS_ROOT}/config/routes.rb")
        ::PluginSystem::Instance.started_plugins.load_order.reverse.each do |plugin|
          routes_file = File.join(plugin.path_to_gem, 'config', 'routes.rb')
          load routes_file if File.file? routes_file
        end
        add_route ':controller/:action/:id'
      end
    end
  end
end
