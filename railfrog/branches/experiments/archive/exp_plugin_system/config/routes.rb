ActionController::Routing::Routes.draw do |map|

  map.rf_admin 'railfrog', :controller => 'railfrog/admin', :action => 'index'

  map.connect ':controller/:action/:id'
  
  # Default route for DB lookup
  map.connect '*path', :controller => 'site_mapper', :action => 'show_chunk'
end
