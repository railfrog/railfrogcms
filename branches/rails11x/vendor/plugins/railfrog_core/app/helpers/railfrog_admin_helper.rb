module RailfrogAdminHelper


  def hide_block(dom_id_segment)
      javascript_tag("if ($('#{dom_id_segment}-nav')) {" +
                       "Element.hide('#{dom_id_segment}-nav');" +
                     "}" +
                     "if ($('#{dom_id_segment}-content')) {" +
                       "Element.hide('#{dom_id_segment}-content');" +
                     "}")
  end


  def block_start(dom_id_segment, heading)
    html =  "<div id=\"#{dom_id_segment}-block\" class=\"block\"><div>"
    html << "  <h2 id=\"#{dom_id_segment}-title\" class=\"block-title\">#{heading}</h2>"

    return html
  end


  def block_end
    html = "</div></div>"

    return html
  end


  def block_nav_start(dom_id_segment)
    html = "<ul id=\"#{dom_id_segment}-nav\" class=\"block-nav horizontal-list\"><div>"

    return html
  end


  def block_nav_end
    html = "</div></ul>"

    return html
  end


  def block_nav_action
    html = '<li>'
    html << yield
    html << '</li>'

    return html
  end


  def block_content_start(dom_id_segment)
    html = "<div id=\"#{dom_id_segment}-content\" class=\"block-content\"><div>"

    return html
  end


  def block_content_end
    html = "</div></div>"

    return html
  end


  # Lists the folders under the given SiteMapping.
  def list_folders(site_mapping)
    html = '<ul id="folders-list-#{site_mapping.id}" class="folders-list relatedcontent">'
    html << folder_tree(site_mapping)

    if site_mapping.child_folders.size == 0
      html << 'No Folders'
      # there are no folders, so hide this block's content
#      html << hide_block('folders')
    end

    html << '</ul>'

    return html
  end


  def folder_tree(site_mapping)
    html = ''

    site_mapping.child_folders.each do |folder|
      html << "<li id=\"folder-item-#{folder.id}\" class=\"folder-item\">"

      if folder.child_folders.size > 0
        html << folder_loading_img(folder, true)
        html << folder_expand_link(folder)
        html << folder_collapse_link(folder, true)
      else
        html << image_tag('empty')
      end

      html << link_to(folder.path_segment, { :action => 'explore', :id => folder.id })

      if folder.child_folders.size > 0
        html << "<div id=\"folder-tree-#{folder.id}\" class=\"folder-tree\">"
        html <<   "<ul id=\"folder-tree-list-#{folder.id}\" class=\"folder-tree-list relatedcontent\"></ul>"
        html << '</div>'
      end

      html << '</li>'
    end

    return html
  end


  def folder_expand_link(folder, hidden=false)
    html = "<span id=\"folder-expand-link-#{folder.id}\"" + (hidden ? ' style="display: none;">' : '>')
    html << link_to_remote(image_tag('collapsed', :id => "folder-expand-img-#{folder.id}", :alt => '>'),
                           { :url => { :action => 'folder_tree', :site_mapping_id => folder.id },
                             :loading => "Element.hide('folder-expand-link-#{folder.id}');" +
                                         "Element.show('folder-loading-img-#{folder.id}');" +
                                         "Element.hide('folder-tree-#{folder.id}');",
                             :update => "folder-tree-list-#{folder.id}",
                             :success => "setTimeout('Element.hide(\"folder-loading-img-#{folder.id}\");" +
                                                     "Element.show(\"folder-collapse-link-#{folder.id}\")', 500);",
                             :failure => "Element.hide('folder-loading-img-#{folder.id}');" +
                                         "Element.show('folder-expand-link-#{folder.id}');",
                             :complete => visual_effect(:slide_down, "folder-tree-#{folder.id}", :duration => 0.5)
                           })
    html << '</span>'

    return html
  end


  def folder_collapse_link(folder, hidden=false)
    html = "<span id=\"folder-collapse-link-#{folder.id}\"" + (hidden ? ' style="display: none;">' : '>')
    html << link_to_function(image_tag('expanded', :id => "folder-collapse-img-#{folder.id}", :alt => 'V'),
                             "Element.hide('folder-collapse-link-#{folder.id}');" +
                             "Element.show('folder-loading-img-#{folder.id}');" +
                             "Effect.SlideUp('folder-tree-#{folder.id}', {duration:0.5});" +
                             "setTimeout('$(\"folder-tree-list-#{folder.id}\").innerHTML = \"\";" +
                                         "Element.hide(\"folder-loading-img-#{folder.id}\");" +
                                         "Element.show(\"folder-expand-link-#{folder.id}\")', 500);")
    html << '</span>'

    return html
  end


  def folder_loading_img(folder, hidden=false)
    return image_tag('folder-loading.gif',
                     :id => "folder-loading-img-#{folder.id}",
                     :style => (hidden ? 'display: none;' : ''))
  end


  # Lists the labels set for the given SiteMapping.
  def list_labels(site_mapping)
    mapping_labels = MappingLabel.find_all_by_site_mapping_id(site_mapping.id)

    html = ''

    if mapping_labels.empty?
      html << '<span>No Labels</span>'
#      html << javascript_tag("if ($('labels-nav')) {" +
#                               "Element.hide('labels-nav');" +
#                             "}" +
#                             "if ($('labels-content')) {" +
#                               "Element.hide('labels-content');" +
#                             "}")
    else
      html << '<table>'

      mapping_labels.each do |mapping_label|
        html << render(:partial => 'mapping_label',
                       :locals => { :mapping_label => mapping_label })
      end

      html << '</table>'
    end

    return html
  end


  # Lists the tags set for the given SiteMapping.
  def list_tags(site_mapping)
    html = ''

    html << '<ul class="relatedcontent">'
    html << '<li>No Tags</li>'
#    html << javascript_tag("if ($('tags-nav')) {" +
#                             "Element.hide('tags-nav');" +
#                           "}" +
#                           "if ($('tags-content')) {" +
#                             "Element.hide('tags-content');" +
#                           "}")
    html << '</ul>'

    return html
  end


  # Lists the files of the given type under the given SiteMapping.
  def list_files(site_mapping, mime_class)
    html  = '<table>'
    html << '<tr><th>ID</th><th>Name</th><th>Updated</th><th>Type</th><th></th></tr>'

    author = 'Unknown'
    updated_at = site_mapping.updated_at

    # the number of items found
    count = 0

    # the individual mime types specified by the mime class
    relevant_mime_types = Array.new
    MimeType.find_by_class(mime_class).each do |mime_type|
      relevant_mime_types << mime_type.mime_type
    end

    site_mapping.direct_children.each do |child|
      # skip if the child is a folder
      next if child.folder?
      # filter out the mime types we don't need
      next if not relevant_mime_types.include?(child.chunk.mime_type.mime_type)

      count += 1

      html << render(:partial => 'file_item',
                     :locals => { :chunk_id => child.chunk.id,
                                  :site_mapping => child,
                                  :mime_class => mime_class,
                                  :author => author,        # FIXME uninitialized and unused
                                  :updated_at => updated_at,
                                  :mime_type => child.chunk.mime_type.mime_type })
    end

    html << '</table>'
    
    if count == 0
      html = '<span>No Files</span>'
#      html << javascript_tag("if ($('#{mime_class}-nav')) {" +
#                               "Element.hide('#{mime_class}-nav');" +
#                             "}" +
#                             "if ($('#{mime_class}-content')) {" +
#                               "Element.hide('#{mime_class}-content');" +
#                             "}")
    end

    return html
  end


end
