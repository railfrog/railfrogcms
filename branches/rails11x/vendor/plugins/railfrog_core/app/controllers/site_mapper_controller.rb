require 'pp'
require 'rubygems'

class SiteMapperController < ApplicationController
  # TODO CHK RE-ENABLE!!! caches_page :show_chunk

  def show_chunk

    path = params[:path]

    @chunk_version, @rf_labels = SiteMapping.find_chunk_and_mapping_labels(path, params[:version], true)

    unless @chunk_version then
      logger.info "Chunk is not found for path: #{path.to_s}. Trying to get index-page: #{@rf_labels['index-page']} ..."
      path.push @rf_labels['index-page']

      @chunk_version, @rf_labels = SiteMapping.find_chunk_and_mapping_labels(path, params[:version])
    end

    if @chunk_version then
      @chunk_content = @chunk_version.content

      # options for sending chunk content back to user
      data_options = {:disposition => 'inline'}

      # If a mime type is specified, use it.
      mime_type = "text/html"
      case @chunk_version.chunk.mime_type.mime_type
        when nil
          # No action
        when "text/x-markdown"
          # Apply BlueCloth for Markdown
          # TODO Check whether BC is available without demanding require_gem ## if (const_defined? 'BlueCloth')
          require_gem 'BlueCloth', '>= 1.0.0'
          @chunk_content = BlueCloth::new(@chunk_content).to_html
          # else
          #   @chunk_content = "<h1>Error: BlueCloth gem not installed</h1>"
          # end
        when "text/x-textile"
          # Apply RedCloth for Textile
          require_gem 'RedCloth', '>= 3.0.0'
          @chunk_content = RedCloth::new(@chunk_content).to_html
        else
          mime_type = @chunk_version.chunk.mime_type.mime_type
      end

      data_options[:type] = mime_type
      data_options[:filename] = @params[:path].last

      if mime_type.include?("html") && params[:layout] != 'false' then
        # it is a html doc, then render our data inside the layout
        layout = @rf_labels['layout']
        rendering_options = {}
        if layout
          if layout.include?("mapping:")
            layout.gsub!("mapping:", "")

            layout_chunk = SiteMapping.find_chunk(layout.split('/'))
            if layout_chunk then
              rendering_options[:inline] = layout_chunk.content
            else
              rendering_options[:inline] = "Couldn't find layout #{layout}"
            end

            @rf_labels["chunk_content"] = @chunk_content
            @rf_labels["chunk-content"] = @chunk_content    # FIXME: Always allow hyphens as alternative to underscore in rf_label[] lookups
          else
            rendering_options[:partial] = "chunk_content"
            rendering_options[:layout] = layout
          end
        else
          rendering_options[:partial] = "chunk_content"
        end

        session[:rf_labels] = @rf_labels
        rendering_options[:locals] = {:rf_labels => @rf_labels}

        data = render_to_string rendering_options
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
