module RailfrogAdminHelper
  TABS = %w{ one two three four }.freeze  

  def create_mapping_tree(mappings, parent_id=0)
    mappings[parent_id].sort! do |x,y|
      if (x.all_children.size == y.all_children.size) || (x.all_children.size > 0 && y.all_children.size > 0)
        (x.path_segment <=> y.path_segment)
      else
        (y.all_children.size <=> x.all_children.size)
      end
    end
    tree = "<div id=\"tree_#{parent_id}\"><ul>"
    for map in mappings[parent_id] do
      tree += '<li>'
      tree += link_to_function('', visual_effect(:toggle_slide, "tree_#{map.id}", :duration => 0.5)+" if (Element.hasClassName('link_tree_#{map.id}', 'expand')) { Element.addClassName('link_tree_#{map.id}', 'collapse'); Element.removeClassName('link_tree_#{map.id}', 'expand'); } else { Element.addClassName('link_tree_#{map.id}', 'expand'); Element.removeClassName('link_tree_#{map.id}', 'collapse'); }", :class => (parent_id == 0 ? 'collapse':'expand'), :id => "link_tree_#{map.id}") if !map.rgt.nil? && !map.lft.nil? && ((map.all_children.size > 0) || map.chunk_id.nil?)
      tree += link_to_remote("#{h((map.path_segment.length > 0 ? map.path_segment : '/'))}", 
        { :url => { :action => 'show', :mapping_id => map.id }}, 
	((map.is_internal) ? {:class => 'internal'} : {}) )
      tree += create_mapping_tree(mappings, map.id) if !map.lft.nil? && map.all_children.size > 0
      tree += '</li>'
    end
    tree += '</ul></div>'
    if parent_id > 1
      tree += javascript_tag("Element.hide('tree_#{parent_id}')") 
    end

    tree
  end

  # Activates given tab and deactivate others. 
  # Shows submenu for active tab and hides all other submenus. 
  def activate_tab(tab)
    # hide all submenus
    (TABS - [ tab ]).each { |item| page.hide item }

    # show submenu of active tab
    page.show tab

    # deactivate all tabs
    page.select('ul#folder_tabs li a').each do |item|
      item.remove_class_name :active
    end

    # activate given tab
    page << "$(this).addClassName('active')"
  end

end

def humanize_markup_name(markup)
  if markup.nil?
    '(unknown)'
  elsif markup.downcase == 'html' || markup == 'text/html'
    'HTML'
  elsif markup.downcase == 'markdown' || markup == 'text/x-markdown'
    'Markdown'
  elsif markup.downcase == 'textile' || markup == 'text/x-textile'
    'Textile'
  else
    markup.humanize
  end
end
