class SiteMapperController < ApplicationController
  # FIXME - disabled caching #  caches_page :show_chunk

  helper_method :render_chunk

  def show_chunk

    path = params[:path]

    logger.info "Looking for site_mapping for #{path.join('/')} path"

    @mapping, @rf_labels, @chunk_version = SiteMapping.find_mapping_and_labels_and_chunk(path, params[:version], true)

    if @mapping.nil? || @mapping.chunk.nil?
      unless @rf_labels.nil?
        logger.info "Chunk is not found for path: #{path.join('/')}. Trying to get index-page: #{@rf_labels['index-page']} ..."
        path.push @rf_labels['index-page']

        @mapping, @rf_labels, @chunk_version = SiteMapping.find_mapping_and_labels_and_chunk(path, params[:version], true)
      end
    end

    if @mapping && @mapping.chunk
      @chunk_content = @mapping.chunk.live_chunk_version.content

      # options for sending chunk content back to user
      data_options = {:disposition => 'inline'}

      if @mapping.chunk.mime_type
        mime_type = @mapping.chunk.mime_type.mime_type
      else
        mime_type = "text/html"
      end

      data_options[:type] = mime_type
      data_options[:filename] = params[:path].last

      if mime_type.include?("html") && params[:layout] != 'false' then
        # it is a html doc, then render our data inside the layout
        layout = @rf_labels['layout']
        rendering_options = {}
        if layout then
          if layout =~ /mapping:(.+)/
            logger.info "Looking for the layout..."
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
