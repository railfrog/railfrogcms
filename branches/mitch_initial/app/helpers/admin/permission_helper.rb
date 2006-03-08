module Admin::PermissionHelper
  def url_for_edit_language(perm)
    url_for :controller => '/admin/permission', :action => 'edit_language', :id => perm.id
  end
  
  def url_for_edit_language_with_ajax(perm)
    url_for :controller => '/admin/permission', :action => 'edit_language_with_ajax', :id => perm.id
  end
  
  def url_for_edit(perm, lang = nil)
    lang = @controller.params[:editlang] if lang.nil?
    url_for :controller => '/admin/permission', :action => 'edit', :id => perm.id, :editlang => lang
  end
  
  def url_for_edit_with_ajax(perm, lang = nil)
    lang = @controller.params[:editlang] if lang.nil?
    url_for :controller => '/admin/permission', :action => 'edit_with_ajax', :id => perm.id, :editlang => lang
  end
  
  def url_for_do_edit(perm, lang = nil)
    lang = @controller.params[:editlang] if lang.nil?
    url_for :controller => '/admin/permission', :action => 'do_edit', :id => perm.id, :editlang => lang
  end
  
  def url_for_do_edit_with_ajax(perm, lang = nil)
    lang = @controller.params[:editlang] if lang.nil?
    url_for :controller => '/admin/permission', :action => 'do_edit_with_ajax', :id => perm.id, :editlang => lang
  end
  
  def url_for_destroy_translation(perm, lang)
    url_for :controller => '/admin/permission', :action => 'destroy_translation', :id => perm.id, :editlang => lang
  end
  
  def url_for_destroy_translation_with_ajax(perm, lang)
    url_for :controller => '/admin/permission', :action => 'destroy_translation_with_ajax', :id => perm.id, :editlang => lang
  end
end
