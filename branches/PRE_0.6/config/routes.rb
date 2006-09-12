ActionController::Routing::Routes.draw do |map|
  map.rf_admin '/admin', :controller => 'railfrog_admin'
  
  #map.resource :user
  #map.resource :group
  
  map.connect ':controller/:action/:id'
  
  # Default route for DB lookup
  map.connect '*path', :controller => 'site_mapper', :action => 'show_chunk'
end
