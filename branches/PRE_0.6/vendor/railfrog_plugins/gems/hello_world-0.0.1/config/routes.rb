ActionController::Routing::Routes.draw_more do |map|
  map.connect 'hello_world/greet/:name', :controller => 'hello_world', :action => 'index'
end