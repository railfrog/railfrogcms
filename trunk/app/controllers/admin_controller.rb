class AdminController < ApplicationController
  layout 'default'
  
  def index
    @site_mappings = SiteMapping.find(:all, :order => 'root_id, lft')
    if params[:mapping_id] then
      @site_mapping = SiteMapping.find(params[:mapping_id])
      @chunk_version = @site_mapping.chunk.find_version() if @site_mapping.chunk
    else
    end
  end
  
  def edit_document
    @chunk_version = ChunkVersion.find(params[:chunk_version_id])
    @chunk = @chunk_version.chunk
  end
  
  def save_document
    @chunk_version = ChunkVersion.find(params[:chunk_version_id])
    @chunk = @chunk_version.chunk
    
    live_version = (@chunk_version.version + 1)
    version = @chunk.chunk_versions.create (params[:chunk_version])
    version.base_version = @chunk_version.version
    version.version = live_version
    version.save

    @chunk.update_attributes(params[:chunk])
    @chunk.live_version = live_version
    @chunk.save
    
    redirect_to :action => 'index'
  end
  
end