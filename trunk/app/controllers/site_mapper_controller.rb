class SiteMapperController < ApplicationController
  layout 'default'
  
  def show_chunk
    @chunk_version, @layout, @site_mapping = SiteMapping.find_chunk_and_layout(@params[:path])
    
    if @chunk_version then
      if @chunk_version.chunk.mime_type then
        mime_type = @chunk_version.chunk.mime_type.mime_type
      else
        mime_type = "text/html"
      end
      send_data @chunk_version.content, :filename => @params[:path].pop, :type => mime_type, :disposition => 'inline' if @chunk_version && @chunk_version.chunk
    else 
      render :partial => "notfound", :status => 404
    end
  end
  
  
end
