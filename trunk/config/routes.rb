ActionController::Routing::Routes.draw do |map|
  # Should the /admin be preserved for RailFrog ?
  map.connect ':controller/:action/:id'
  
  # Default route for DB lookup
  map.connect '', :controller => 'site_mapper', :action => 'show_chunk', :path => ["index.html"]
  map.connect '*path', :controller => 'site_mapper', :action => 'show_chunk'
end
