module RailfrogAdminHelper
  def create_mapping_tree(mappings, parent_id=0)
    mappings[parent_id].sort! do |x,y| 
      if (x.children_count == y.children_count) || (x.children_count > 0 && y.children_count > 0)
        (x.path_segment <=> y.path_segment) 
      else
        (y.children_count <=> x.children_count) 
      end
    end
    tree = "<div id=\"tree_#{parent_id}\"><ul>"
    for map in mappings[parent_id] do
      tree += '<li>'
      tree += link_to_function('', visual_effect(:toggle_slide, "tree_#{map.id}", :duration => 0.5)+" if (Element.hasClassName('link_tree_#{map.id}', 'expand')) { Element.addClassName('link_tree_#{map.id}', 'collapse'); Element.removeClassName('link_tree_#{map.id}', 'expand'); } else { Element.addClassName('link_tree_#{map.id}', 'expand'); Element.removeClassName('link_tree_#{map.id}', 'collapse'); }", :class => 'expand', :id => "link_tree_#{map.id}") if (map.children_count > 0) || map.chunk_id.nil?
      tree += link_to_remote("#{h((map.path_segment.length > 0 ? map.path_segment : '/'))}", :update => 'content_block', :url => { :action => 'show', :mapping_id => map.id })
      tree += create_mapping_tree(mappings, map.id) if (map.children_count > 0)
      tree += '</li>'
    end
    tree += '</ul></div>'
    if parent_id != 0
      tree += javascript_tag("Element.hide('tree_#{parent_id}')")
    end
    tree
  end
end
