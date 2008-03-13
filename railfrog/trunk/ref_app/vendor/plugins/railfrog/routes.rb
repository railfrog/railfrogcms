rf_admin '/admin', :controller => 'railfrog_admin'

connect ':controller/:action/:id'
  
# Default route for DB lookup
connect '*path', :controller => 'site_mapper', :action => 'show_chunk'
