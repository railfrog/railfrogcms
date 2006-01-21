module Admin::ExtensionHelper
  def url_for_install(ext_name)
    url_for :controller => '/admin/extension', :action => 'install', :id => ext_name
  end
  
  def url_for_install_with_ajax(ext_name)
    url_for :controller => '/admin/extension', :action => 'install_ajax', :id => ext_name
  end
  
  def url_for_uninstall(ext_name)
    url_for :controller => '/admin/extension', :action => 'uninstall', :id => ext_name
  end
  
  def url_for_uninstall_with_ajax(ext_name)
    url_for :controller => '/admin/extension', :action => 'uninstall_ajax', :id => ext_name
  end
end
