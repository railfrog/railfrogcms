ActionController::Routing::Routes.draw do |map|

  map.connect ':controller/:action/:id'
  
  # Default route for DB lookup
  map.connect '*path', :controller => 'site_mapper', :action => 'show_chunk'
end
