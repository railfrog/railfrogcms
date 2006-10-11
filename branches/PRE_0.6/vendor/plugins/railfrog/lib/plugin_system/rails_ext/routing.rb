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
        default_route = routes.pop if !routes.empty? && routes.last.segments.map(&:to_s).join('') == '/:controller/:action/:id/' # TODO: remove this ...
        ::PluginSystem::Instance.started_plugins.load_order.reverse.each do |plugin|
          routes_file = File.join(plugin.path_to_gem, 'config', 'routes.rb')
          load routes_file if File.file? routes_file
        end
        routes << default_route if default_route # TODO: ... and this in favour of something better. What about draw_foreground, draw_background?
      end
    end
  end
end
