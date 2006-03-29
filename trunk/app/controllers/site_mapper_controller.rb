class SiteMapperController < ApplicationController
  layout 'default'
  
  def show_chunk
    @chunk_version, @layout = SiteMapping.find_chunk_and_layout(@params[:path])
    
    mime_type = @chunk_version.chunk.mime_type.mime_type if @chunk_version.chunk.mime_type
    send_data @chunk_version.content, :filename => @params[:path].pop, :type => mime_type, :disposition => 'inline' if @chunk_version && @chunk_version.chunk
        
    redirect_to :action => 'notfound' unless @chunk_version
  end
  
  # 404 action
  def notfound
  end
end
