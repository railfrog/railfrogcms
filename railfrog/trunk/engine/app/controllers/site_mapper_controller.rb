require 'rubygems'
require 'railfrog'

class SiteMapperController < ApplicationController
=begin
  helper_method :expire
  
  def expire(path)
    expire_page :controller => 'site_mapper', 
      :action => 'show_chunk',
      :path => path.split('/')
  end
  caches_page :show_chunk
=end  


  helper_method :render_chunk

  # retrieve chunk for :path (and optional :version), apply appropriate layout if specified, set content-type and render
  # params[:path] - # array of path segments
  # params[:version] - if specified, retrieve this version, otherise retrieve version marked as live
  def show_chunk
    path = params[:path]
    logger.debug "show_chunk >>>> looking for site_mapping for path: \'#{path.join('/')}\'"

    @mapping, @rf_labels, @chunk_version = SiteMapping.find_mapping_and_labels_and_chunk(path, params[:version], true)
    if @mapping.nil? || @mapping.chunk.nil?
      # TODO: do *not* return /foo/bar/index.html for /foo/bar -- see ticket:182
      index_page = @rf_labels['index_page'] unless @rf_labels.nil?
      index_page = "index.html" if index_page.nil? || index_page.empty?
      logger.debug "show_chunk >>>> chunk not found for path: \'#{path.join('/')}\', trying to get index-page: \'#{index_page}\' ..."
      path.push index_page
      @mapping, @rf_labels, @chunk_version = SiteMapping.find_mapping_and_labels_and_chunk(path, params[:version], true)
    end
    logger.debug "show_chunk >>>> mapping for path  \'#{path.join('/')}\' is #{@mapping.id}" if @mapping
    if @mapping && @mapping.chunk     # this is a data node, since a folder node will not have an associated chunk
      @chunk_content = @mapping.chunk.live_chunk_version.content

      # options for sending chunk content back to user -- see docs for #render
      data_options = {:disposition => 'inline'}
      render_mt = Mime::HTML.to_str
      if @mapping.chunk.mime_type_str && !@mapping.chunk.mime_type_str.empty?
        requested_mt = Mime::HTML.to_str  #  TODO: use respond_to and file extension to determine the requested mime type
        chunk_mt = Mime::Type.lookup(@mapping.chunk.mime_type_str).to_str    # Normalize in case of synonyms
        tm = Railfrog::Transform::TransformManager.instance
        @chunk_content, render_mt = tm.transform(@chunk_content, chunk_mt, requested_mt)
      end
      logger.debug "show_chunk >>>> render_mt is \'#{render_mt}\'"

      data_options[:type] = render_mt
      data_options[:filename] = params[:path].last

      if data_options[:type].include?("html") && params[:layout] != 'false' then
        # if it is an html doc, then render our data inside the layout
        layout = @rf_labels['layout']
        logger.debug "show_chunk >>>> rf_labels sets layout to #{layout}"
        rendering_options = {}
        if layout then
          if layout =~ /mapping:(.+)/
            layout_mapping = SiteMapping.find_mapping($1.split('/'))

            if layout_mapping && layout_mapping.chunk
              rendering_options[:inline] = layout_mapping.chunk.live_chunk_version.content
            else
              rendering_options[:inline] = "Couldn't find layout #{layout}" 
            end

            @rf_labels["chunk_content"] = @chunk_content
            @rf_labels["chunk-content"] = @chunk_content    # Allow either hyphen or underscore
          else
            rendering_options[:partial] = "chunk_content"
            rendering_options[:layout] = layout
          end
        else
          rendering_options[:partial] = "chunk_content"
        end

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
    render_to_string :inline => Chunk.find_version(options).content, :locals => {:rf_labels => @rf_labels }
  end
end
