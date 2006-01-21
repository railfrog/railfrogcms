module Admin::ThemeHelper
  def url_for_activate(theme)
    url_for :controller => '/admin/theme', :action => 'activate', :id => theme['id']
  end
  
  def url_for_activate_with_ajax(theme)
    url_for :controller => '/admin/theme', :action => 'activate_with_ajax', :id => theme['id']
  end
  
  def url_for_templates(theme)
    theme = theme.is_a?(String) ? theme : theme['id']
    url_for :controller => '/admin/theme', :action => 'templates', :id => theme
  end
  
  def url_for_templates_with_ajax(theme)
    theme = theme.is_a?(String) ? theme : theme['id']
    url_for :controller => '/admin/theme', :action => 'templates_with_ajax', :id => theme
  end
  
  def url_for_edit_template(theme, template)
    url_for :controller => '/admin/theme', :action => 'edit_template', :edittheme => theme, :template => template
  end
  
  def url_for_edit_template_with_ajax(theme, template)
    url_for :controller => '/admin/theme', :action => 'edit_template_with_ajax', :edittheme => theme, :template => template
  end
  
  def url_for_do_edit_template_with_ajax(theme, template)
    url_for :controller => '/admin/theme', :action => 'do_edit_template_with_ajax', :edittheme => theme, :template => template
  end
  
  def url_for_do_edit_template(theme, template)
    url_for :controller => '/admin/theme', :action => 'do_edit_template', :edittheme => theme, :template => template
  end
  
  def url_for_view_template_with_ajax(theme, template)
    url_for :controller => '/admin/theme', :action => 'view_template_with_ajax', :edittheme => theme, :template => template
  end
  
  def url_for_view_template(theme, template)
    url_for :controller => '/admin/theme', :action => 'view_template', :edittheme => theme, :template => template
  end
  
  def url_for_raw_view_template(theme, template)
    url_for :controller => '/admin/theme', :action => 'raw_view_template', :edittheme => theme, :template => template
  end
end
