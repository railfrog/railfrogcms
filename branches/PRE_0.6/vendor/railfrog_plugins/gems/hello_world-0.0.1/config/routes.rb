ActionController::Routing::Routes.add_maps do |map|
  map.connect 'hello_world/greet/:name', :controller => 'hello_world', :action => 'index'
end