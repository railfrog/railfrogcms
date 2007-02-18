module ActionController
  module Routing
    class RouteSet
      def draw_more
        yield Mapper.new(self)
        named_routes.install
      end
      
      alias :railfrog_original_load_routes! :load_routes!
      def load_routes!
        railfrog_original_load_routes!
        ::PluginSystem::Instance.started_plugins.load_order.reverse.each do |plugin|
          routes_file = File.join(plugin.path_to_gem, 'config', 'routes.rb')
          load routes_file if File.file? routes_file
        end
      end
    end
  end
end
