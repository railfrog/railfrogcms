class SiteMapperController < ApplicationController
  # FIXME - disabled caching #  caches_page :show_chunk

  helper_method :render_chunk

  # retrieve chunk for :path (and optional :version), apply appropriate layout if specified, set content-type and render
  # params[:path] - # array of path segments
  # params[:version] - if specified, retrieve this version, otherise retrieve version marked as live
  def show_chunk
    path = params[:path]
    logger.info "Looking for site_mapping for path: \'#{path.join('/')}\'"

    @mapping, @rf_labels, @chunk_version = SiteMapping.find_mapping_and_labels_and_chunk(path, params[:version], true)
    if @mapping.nil? || @mapping.chunk.nil?
      # FIXME: do *not* return /foo/bar/index.html for /foo/bar -- only for /foo/bar/ ; use redirect if /foo/bar is requested
      index_page = @rf_labels['index_page'] unless @rf_labels.nil?
      index_page = "index.html" if index_page.nil? || index_page.empty?
      logger.info "Chunk not found for path: \'#{path.join('/')}\'. Trying to get index-page: \'#{index_page}\' ..."
      path.push index_page
      @mapping, @rf_labels, @chunk_version = SiteMapping.find_mapping_and_labels_and_chunk(path, params[:version], true)
    end
    logger.debug "mapping for path  \'#{path.join('/')}\' is \'#{@mapping}\'"
    if @mapping && @mapping.chunk     # this is a data node, since a folder node will not have an associated chunk
      @chunk_content = @mapping.chunk.live_chunk_version.content

      # options for sending chunk content back to user -- see docs for #render
      data_options = {:disposition => 'inline'}

      if @mapping.chunk.mime_type_str && !@mapping.chunk.mime_type_str.empty?
        mime_type_str = @mapping.chunk.mime_type_str
      else
        mime_type_str = "text/html"
      end
      logger.debug "mime_type_str is \'#{mime_type_str}\'"

      data_options[:type] = mime_type_str
      data_options[:filename] = params[:path].last

      if mime_type_str.include?("html") && params[:layout] != 'false' then
        # if it is an html doc, then render our data inside the layout
        layout = @rf_labels['layout']
        logger.debug("rf_labels sets layout to #{layout}")
        rendering_options = {}
        if layout then
          if layout =~ /mapping:(.+)/
            logger.debug "Looking for the layout..."
            layout_mapping = SiteMapping.find_mapping($1.split('/'))

            if layout_mapping && layout_mapping.chunk
              rendering_options[:inline] = layout_mapping.chunk.live_chunk_version.content
            else
              rendering_options[:inline] = "Couldn't find layout #{layout}" 
            end

            @rf_labels["chunk_content"] = @chunk_content
          else
            rendering_options[:partial] = "chunk_content"
            rendering_options[:layout] = layout
          end
        else
          rendering_options[:partial] = "chunk_content"
        end

        session[:rf_labels] = @rf_labels
        rendering_options[:locals] = {:rf_labels => @rf_labels}

        begin
          data = render_to_string rendering_options
        rescue Exception => exc
          data = %Q{<h1>500 Railfrog Error</h1>
            <p>Message: #{exc.message}</p>
            <p>#{exc.backtrace.join("<br />")}</p>}

          data_options[:status] = 500
        end
      else
        data = @chunk_content
      end

      send_data data, data_options
    else
      render :partial => "notfound", :status => 404
    end
  end

  private
  def render_chunk(options)
    render_to_string :inline => Chunk.find_version(options).content, :locals => {:rf_labels => session[:rf_labels]}
  end
end
