# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Railfrog

  def javascript_selective_enabler
    javascript_tag "document.getElementsByClassName('js-true').each(function(e) { Element.removeClassName(e, 'js-true'); });" +
                   "document.getElementsByClassName('js-false').each(function(e) { Element.hide(e); });"
  end

  def print_site_mappings(site_mapping)
    html = '' if html.nil?
    
    if site_mapping.parent_id == 0
      html << '<li>' << link_to('ROOT', { :action => 'explore', :id => site_mapping.id }) << '</li>'
    else
      html = '<li> / ' + link_to(site_mapping.path_segment,
                                 { :action => 'explore', :id => site_mapping.id }) + '</li>' + html
      html = print_site_mappings(SiteMapping.find(site_mapping.parent_id)) + html
    end
    
    return html
  end
end
