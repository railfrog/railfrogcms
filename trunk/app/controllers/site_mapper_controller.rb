class SiteMapperController < ApplicationController
  # FIXME - disabled caching #  caches_page :show_chunk

  def show_chunk

    path = params[:path]

    @mapping, @rf_labels, @chunk_version = SiteMapping.find_mapping_and_labels_and_chunk(path, params[:version], true)

    if @chunk_version.nil?
      unless @rf_labels.nil?
        logger.info "Chunk is not found for path: #{path.join('/')}. Trying to get index-page: #{@rf_labels['index-page']} ..."
        path.push @rf_labels['index-page']

        @mapping, @rf_labels, @chunk_version = SiteMapping.find_mapping_and_labels_and_chunk(path, params[:version], true)
      end
    end

    if @chunk_version then
      @chunk_content = @chunk_version.content

      # options for sending chunk content back to user
      data_options = {:disposition => 'inline'}

      if @chunk_version.chunk.mime_type then
        mime_type = @chunk_version.chunk.mime_type.mime_type
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
            layout_chunk = SiteMapping.find_chunk($1.split('/'))
            if layout_chunk
              rendering_options[:inline] = layout_chunk.content
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
          data = %Q{<h1>500 RailFrog Error</h1>
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

  hide_action :render_chunk
  def render_chunk(options)
    render_to_string :inline => Chunk.find_version(options).content, :locals => {:rf_labels => session[:rf_labels]}
  end
end
