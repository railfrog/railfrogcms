class SiteMapperController < ApplicationController
  layout 'default'
  
  def show_chunk
    @chunk_version, @layout = SiteMapping.find_chunk_and_layout(@params[:path])
    send_data @chunk_version.content, :filename => @params[:path].to_s, :type => @chunk_version.chunk.mime_type, :disposition => 'inline' if @chunk_version && @chunk_version.chunk && @chunk_version.chunk.is_binary?
    redirect_to :action => 'notfound' unless @chunk_version
  end
  
  # 404 action
  def notfound
  end
end
