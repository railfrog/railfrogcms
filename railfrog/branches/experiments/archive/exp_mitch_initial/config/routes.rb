ActionController::Routing::Routes.draw do |map|
  # Admin pages...
  map.connect ':controller/:action', :action => 'index', :requirements => { :controller => /^admin(\/[a-z_A-Z]*)?$/ }
  map.connect 'admin/item/extension/:extension_id/:extension_method/:id', :controller => 'admin/item', :action => 'extension'
  map.connect 'admin/item/extension/ajax/:extension_id/:extension_method/:id', :controller => 'admin/item', :action => 'extension_ajax'
  
  # Account
  map.connect 'account/:action/:id', :id => nil, :controller => 'account'
  
  # Themes
  map.connect 'theme/:theme/:resource/:filename', :controller => 'theme', :action => 'resource'
  map.connect 'theme/:resource/:filename', :controller => 'theme', :action => 'resource'
  
  # Items
  map.connect ':item', :controller => 'item', :action => 'view_item'
  map.connect ':item/:method', :controller => 'item', :action => 'run_item'
  
  # The boring stuff
  map.connect ':controller/:action/:id'
  map.connect '', :controller => 'item', :action => 'view_item', :item => ''
end
