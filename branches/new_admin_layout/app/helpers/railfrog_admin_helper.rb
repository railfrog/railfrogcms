module RailfrogAdminHelper

  def block_start(dom_id_segment, heading)
    html =  "<div id=\"#{dom_id_segment}-block\" class=\"block\">"
    html << "  <h2 id=\"#{dom_id_segment}-title\" class=\"block-title\">#{heading}</h2>"

    html << "  <ul id=\"#{dom_id_segment}-actions\" class=\"block-actions horizontal-list\">"
    html << block_action_collapse(dom_id_segment)
    html << "  </ul>"
    
    return html
  end


  def block_end
    html = "</div>"

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


  def block_content_start(dom_id_segment)
    html = "<div id=\"#{dom_id_segment}-content\" class=\"block-content\"><div>"

    return html
  end


  def block_content_end
    html = "</div></div>"

    return html
  end
  
  
  def block_action_collapse(dom_segment_id)
    onclick_js = "if ($('#{dom_segment_id}-nav')) {" +
                   visual_effect(:toggle_slide, "#{dom_segment_id}-nav", :duration => 0.5) +
                 "}" +
                 "if ($('#{dom_segment_id}-content')) {" +
                   visual_effect(:toggle_slide, "#{dom_segment_id}-content", :duration => 0.5) +
                 "}" +
                 "if ($('#{dom_segment_id}-action-collapse-image').src.match('expanded')) {" +
                 "  $('#{dom_segment_id}-action-collapse-image').src = '#{image_path('collapsed')}'" +
                 "} else {" +
                 "  $('#{dom_segment_id}-action-collapse-image').src = '#{image_path('expanded')}'" +
                 "}"

    html  = "<li id=\"#{dom_segment_id}-action-collapse\" class=\"action-collapse\" " +
                "onclick=\"#{onclick_js.gsub("\"", "'")}\">"
    html << image_tag('expanded',
                      :size => '10x10',
                      :alt => 'V',
                      :id => "#{dom_segment_id}-action-collapse-image",
                      :class => 'js-true')
    html << '</li>'

    return html
  end


  # Lists the folders under the given SiteMapping.
  def list_folders(site_mapping)
    html = '<ul id="folders-list" class="relatedcontent">'

    # the number of folders found
    count = 0

    site_mapping.direct_children.each do |child|
      # if the chunk_id ain't nil, it ain't a folder (so go onto the next one)
      next if not child.chunk_id.nil?
      
      count += 1

      html << folder_row(child)
    end
    
    if count == 0
      html << 'No Folders'
      html << javascript_tag("if ($('folders-nav')) {" +
                               "Element.hide('folders-nav');" +
                             "}" +
                             "if ($('folders-content')) {" +
                               "Element.hide('folders-content');" +
                             "}" +
                             "$('folders-action-collapse-image').src = '#{image_path('collapsed')}';")
    end
    
    html << '</ul>'

    return html
  end


  def folder_row(site_mapping)
    html = ''
    child_folders = Array.new
    
    # default to empty class (no children that are folders)
    e_class = 'empty'

    # check if this SiteMapping has children, and assign an appropriate class
    if site_mapping.direct_children.length > 0
      # check if any of the children are folders
      site_mapping.direct_children.each do |child|
        next if not child.chunk_id.nil?

        e_class = 'expanded'

        # push the child folder onto the stack of child folders to render
        child_folders << child
      end
    end

    html << render(:partial => 'folder_item',
                   :locals => { :site_mapping => site_mapping, :e_class => e_class })


    html << "<ul id=\"folder-tree-#{site_mapping.id}\" class=\"relatedcontent\">"
    child_folders.each { |child| html << folder_row(child) }
    html << '</ul>'

    # we only want the collapsed class if JS is available, and the element has children
    # and use JS to hide the element if it has children (so it remains visible without JS)
    html << javascript_tag("if (Element.hasClassName('folder-#{site_mapping.id}', 'expanded')) {" +
                             "Element.addClassName('folder-#{site_mapping.id}', 'collapsed');" +
                             "Element.removeClassName('folder-#{site_mapping.id}', 'expanded');" +
                           "}" +
                           "if (Element.hasClassName('folder-#{site_mapping.id}', 'collapsed')) {" +
                             "Element.hide('folder-tree-#{site_mapping.id}');" +
                           "}")

    return html
  end


  # Lists the labels set for the given SiteMapping.
  def list_labels(site_mapping)
    mapping_labels = MappingLabel.find_all_by_site_mapping_id(site_mapping.id)

    html = ''

    if mapping_labels.empty?
      html << '<span>No Labels</span>'
      html << javascript_tag("if ($('labels-nav')) {" +
                               "Element.hide('labels-nav');" +
                             "}" +
                             "if ($('labels-content')) {" +
                               "Element.hide('labels-content');" +
                             "}" +
                             "$('labels-action-collapse-image').src = '#{image_path('collapsed')}';")
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
    html << javascript_tag("if ($('tags-nav')) {" +
                             "Element.hide('tags-nav');" +
                           "}" +
                           "if ($('tags-content')) {" +
                             "Element.hide('tags-content');" +
                           "}" +
                           "$('tags-action-collapse-image').src = '#{image_path('collapsed')}';")
    html << '</ul>'

    return html
  end


  # Lists the files of the given type under the given SiteMapping.
  def list_files(site_mapping, mime_class)
    html  = '<table>'
    html << '<tr><th>Name</th><th>Author</th><th>Updated</th><th></th></tr>'
    
    author = 'Unknown'
    updated_at = site_mapping.updated_at

    # the number of folders found
    count = 0

    # the individual mime types specified by the mime class
    mime_types = Array.new
    MimeType.find_by_class(mime_class).each do |mime_type|
      mime_types << mime_type.mime_type
    end

    site_mapping.direct_children.each do |child|
      # if the chunk_id is nil, it ain't a file (so go onto the next one)
      next if child.chunk_id.nil?
      # filter out the mime types we don't need
      next if not mime_types.include?(child.chunk.mime_type.mime_type)

      count += 1

      html << render(:partial => 'file_item',
                     :locals => { :site_mapping => child,
                                  :mime_class => mime_class,
                                  :author => author,
                                  :updated_at => updated_at })
    end

    if count == 0
      html << '<span>No Files</span>'
      html << javascript_tag("if ($('#{mime_class}-nav')) {" +
                               "Element.hide('#{mime_class}-nav');" +
                             "}" +
                             "if ($('#{mime_class}-content')) {" +
                               "Element.hide('#{mime_class}-content');" +
                             "}" +
                             "$('#{mime_class}-action-collapse-image').src = '#{image_path('collapsed')}';")
    end

    html << '</table>'

    return html
  end


end
