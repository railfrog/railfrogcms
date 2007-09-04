ActionController::Routing::Routes.draw_more do |map|
  map.resources :users, :controller => 'fucd_rbac/users', :name_prefix => 'fucd_rbac_', :path_prefix => '/railfrog'
  
  map.with_options :controller => 'fucd_rbac/memberships' do |membership|
    membership.fucd_rbac_user_memberships '/railfrog/users/:user_id/memberships', :action => 'edit',   :conditions => { :method => :get }
    membership.connect                    '/railfrog/users/:user_id/memberships', :action => 'update', :conditions => { :method => :put }
  end
  
  map.resources :roles, :controller => 'fucd_rbac/roles', :name_prefix => 'fucd_rbac_', :path_prefix => '/railfrog'
  
  map.with_options :controller => 'fucd_rbac/permissions' do |permission|
    permission.fucd_rbac_permissions     '/railfrog/roles/:role_id/permissions',     :action => 'index',   :conditions => { :method => :get    }
    permission.connect                   '/railfrog/roles/:role_id/permissions',     :action => 'create',  :conditions => { :method => :post   }
    permission.fucd_rbac_new_permission  '/railfrog/roles/:role_id/permissions/new', :action => 'new',     :conditions => { :method => :get    }
    permission.fucd_rbac_edit_permission '/railfrog/roles/:role_id/permissions/:id', :action => 'edit',    :conditions => { :method => :get    }
    permission.fucd_rbac_permission      '/railfrog/roles/:role_id/permissions/:id', :action => 'update',  :conditions => { :method => :put    }
    permission.connect                   '/railfrog/roles/:role_id/permissions/:id', :action => 'destroy', :conditions => { :method => :delete }
  end
  
  map.with_options :controller => 'fucd_rbac/memberships' do |membership|
    membership.fucd_rbac_role_memberships '/railfrog/roles/:role_id/memberships', :action => 'edit',   :conditions => { :method => :get }
    membership.connect                    '/railfrog/roles/:role_id/memberships', :action => 'update', :conditions => { :method => :put }
  end
  
  map.with_options :controller => 'fucd_rbac/login' do |login|
    login.fucd_rbac_login '/railfrog/login', :action => 'new',     :conditions => { :method => :get    }
    login.connect         '/railfrog/login', :action => 'create',  :conditions => { :method => :post   }
    login.connect         '/railfrog/login', :action => 'destroy', :conditions => { :method => :delete }
  end
end
