ActionController::Routing::Routes.draw do |map|
  # Should the /admin be preserved for RailFrog ?
  map.connect 'admin/:controller/:action/:id'
  
  map.connect 'admin/:action/:id'
  
  # Default route for DB lookup
  map.connect '*path', :controller => 'site_mapper', :action => 'show_chunk'
end
