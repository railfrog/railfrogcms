module Admin::ItemHelper
  def url_for_quick_edit_with_ajax
    url_for :controller => '/admin/item', :action => 'quickedit_ajax'
  end
  
  def url_for_quick_edit
    url_for :controller => '/admin/item', :action => 'quickedit'
  end
  
  def url_for_extension_method(item_id, extension_id, method, ajax = false)
    lang = @controller.params[:editlang] if lang.nil?
    lang = Locale.language.iso_639_2 if lang.nil?
    return url_for :controller => '/admin/item', :action => 'extension', :id => item_id, :extension_id => extension_id, :extension_method => method, :editlang => lang unless ajax
    url_for :controller => '/admin/item', :action => 'extension_ajax', :id => item_id, :extension_id => extension_id, :extension_method => method, :editlang => lang
  end
  
  def url_for_create
    url_for :controller => '/admin/item', :action => 'create'
  end
  
  def url_for_create_with_ajax
    url_for :controller => '/admin/item', :action => 'create_with_ajax'
  end
  
  def url_for_destroy(item)
    url_for :controller => '/admin/item', :action => 'destroy', :id => item.id
  end
  
  def url_for_destroy_with_ajax(item)
    url_for :controller => '/admin/item', :action => 'destroy_with_ajax', :id => item.id
  end

  def url_for_edit(item, lang = nil)
    lang = @controller.params[:editlang] if lang.nil?
    url_for :controller => '/admin/item', :action => 'edit', :id => item.id, :editlang => lang
  end
  
  def url_for_edit_with_ajax(item, lang = nil)
    lang = @controller.params[:editlang] if lang.nil?
    url_for :controller => '/admin/item', :action => 'edit_with_ajax', :id => item.id, :editlang => lang
  end
  
  def url_for_quickedit_content
    url_for :controller => '/admin/item', :action => 'do_quickedit_content'
  end
  
  def url_for_quickedit_content_with_ajax
    url_for :controller => '/admin/item', :action => 'do_quickedit_content_ajax'
  end
  
  def url_for_edit_language(item)
    url_for :controller => '/admin/item', :action => 'edit_language', :id => item.id
  end
  
  def url_for_edit_language_with_ajax(item)
    url_for :controller => '/admin/item', :action => 'edit_language_ajax', :id => item.id
  end
  
  def url_for_do_rename(item)
    url_for :controller => '/admin/item', :action => 'do_rename', :id => item.id
  end
  
  def url_for_do_rename_with_ajax(item)
    url_for :controller => '/admin/item', :action => 'do_rename_with_ajax', :id => item.id
  end
end
