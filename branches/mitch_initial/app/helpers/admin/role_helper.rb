module Admin::RoleHelper
  def url_for_edit_language(role)
    url_for :controller => '/admin/role', :action => 'edit_language', :id => role.id
  end
  
  def url_for_edit_language_with_ajax(role)
    url_for :controller => '/admin/role', :action => 'edit_language_with_ajax', :id => role.id
  end
  
  def url_for_destroy_translation(role, lang)
    url_for :controller => '/admin/role', :action => 'destroy_translation', :id => role.id, :editlang => lang
  end
  
  def url_for_destroy_translation_with_ajax(role, lang)
    url_for :controller => '/admin/role', :action => 'destroy_translation_with_ajax', :id => role.id, :editlang => lang
  end
  
  def url_for_edit(role, lang = nil)
    lang = @controller.params[:editlang] if lang.nil?
    url_for :controller => '/admin/role', :action => 'edit', :id => role.id, :editlang => lang
  end
  
  def url_for_edit_with_ajax(role, lang = nil)
    lang = @controller.params[:editlang] if lang.nil?
    url_for :controller => '/admin/role', :action => 'edit_with_ajax', :id => role.id, :editlang => lang
  end
  
  def url_for_do_edit(role, lang = nil)
    lang = @controller.params[:editlang] if lang.nil?
    url_for :controller => '/admin/role', :action => 'do_edit', :id => role.id, :editlang => lang
  end
  
  def url_for_do_edit_with_ajax(role, lang = nil)
    lang = @controller.params[:editlang] if lang.nil?
    url_for :controller => '/admin/role', :action => 'do_edit_with_ajax', :id => role.id, :editlang => lang
  end
  
  def url_for_permissions(role)
    url_for :controller => '/admin/role', :action => 'permissions', :id => role.id
  end
  
  def url_for_permissions_with_ajax(role)
    url_for :controller => '/admin/role', :action => 'permissions_with_ajax', :id => role.id
  end
  
  def url_for_do_permissions(role)
    url_for :controller => '/admin/role', :action => 'do_permissions', :id => role.id
  end
  
  def url_for_do_permissions_with_ajax(role)
    url_for :controller => '/admin/role', :action => 'do_permissions_with_ajax', :id => role.id
  end
  
  def url_for_edit_parent(role)
    url_for :controller => '/admin/role', :action => 'edit_parent', :id => role.id
  end
  
  def url_for_edit_parent_with_ajax(role)
    url_for :controller => '/admin/role', :action => 'edit_parent_with_ajax', :id => role.id
  end
end
