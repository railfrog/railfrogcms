class AdminController < ApplicationController
  layout 'default'
  
  def index
    @site_mappings = SiteMapping.find(:all, :order => 'root_id, lft')
    if params[:chunk_id] then
      @chunk_version = Chunk.find_version(params[:chunk_id])
    else
      @chunk_version = SiteMapping.find_chunk("")
    end
    puts @chunk_version
  end
end