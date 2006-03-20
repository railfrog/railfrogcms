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
  
  def new_document
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:mapping_id]
    
    @chunk = Chunk.new
    @chunk_version = ChunkVersion.new
  end

  def store_document
    chunk = Chunk.new(params[:chunk])
    chunk.live_version = 1
    chunk.save

    chunk_version = chunk.chunk_versions.create(params[:chunk_version])
    chunk_version.version = 1
    chunk_version.save

    site_mapping = SiteMapping.new(params[:site_mapping])
    site_mapping.chunk_id = chunk.id
    site_mapping.lft = 0
    site_mapping.rgt = 0
    site_mapping.depth = 0
    site_mapping.parent_id = 0 unless site_mapping.parent_id
    site_mapping.save
    
    redirect_to :action => 'index'
  end
  
  def edit_document
    @site_mapping = SiteMapping.find(params[:site_mapping_id])
    @chunk_version = ChunkVersion.find(params[:chunk_version_id])
    @chunk = @chunk_version.chunk
  end

  def update_document
    @site_mapping = SiteMapping.find(params[:site_mapping_id])
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
    
    @site_mapping.update_attributes(params[:site_mapping])
    @site_mapping.save
    
    redirect_to :action => 'index'
  end
  
end