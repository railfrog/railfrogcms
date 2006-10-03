ActionController::Routing::Routes.draw_more do |map|
  map.railfrog_resources :users
  map.with_options :controller => 'railfrog/memberships' do |membership|
    membership.railfrog_user_memberships 'railfrog/users/:user_id/memberships', :action => 'edit',   :conditions => { :method => :get }
    membership.connect                   'railfrog/users/:user_id/memberships', :action => 'update', :conditions => { :method => :put }
  end
  
  map.railfrog_resources :roles do |role|
    role.railfrog_resources :permissions
  end
  map.with_options :controller => 'railfrog/memberships' do |membership|
    membership.railfrog_role_memberships 'railfrog/roles/:role_id/memberships', :action => 'edit',   :conditions => { :method => :get }
    membership.connect                   'railfrog/roles/:role_id/memberships', :action => 'update', :conditions => { :method => :put }
  end
  
  map.with_options :controller => 'railfrog/login' do |login|
    login.railfrog_login 'railfrog/login', :action => 'new',     :conditions => { :method => :get    }
    login.connect        'railfrog/login', :action => 'create',  :conditions => { :method => :post   }
    login.connect        'railfrog/login', :action => 'destroy', :conditions => { :method => :delete }
  end
end
