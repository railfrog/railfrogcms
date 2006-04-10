class AdminController < ApplicationController
  before_filter :ensure_logged_in

  layout 'default'
  

  def index
    @site_mappings = SiteMapping.find(:all, :order => 'root_id, lft')
  end

  def show_chunk
    disposition = 'inline'
    if params[:mapping_id] then
      @site_mapping = SiteMapping.find(params[:mapping_id])
      if @site_mapping && @site_mapping.chunk then
        @chunk = @site_mapping.chunk
        @file_name = @site_mapping.full_path
        @mapping_labels = @site_mapping.mapping_labels #TODO Also look up lables inherited from parents?
        @mapping_id = params[:mapping_id]
      end
    elsif params[:chunk_id] then
      @chunk = Chunk.find(params[:chunk_id])
      @file_name = @chunk.id #TODO Change this to a URL that it can render? Right now will generate error in view if you click on "view" link.
    end
    if @chunk then
      mime_type = @chunk.mime_type.mime_type
      @chunk_version = @chunk.find_version()
      if @chunk_version then 
        if mime_type.include?("image") then
          @chunk_content = "<img src='#{@file_name}' />"
        else
          @chunk_content = @chunk_version.content
        end
        content = render_to_string :partial => 'chunk_content', :layout => "default"
        send_data content, :filename => @file_name, :type => mime_type, :disposition => disposition
      end
    else
      content = render_to_string :partial => 'folder_content'
      send_data content, :filename => @file_name, :type => "text/html", :disposition => disposition
    end
  end

  def save_site_mapping_label
    if params[:label_id]
      ml = MappingLabel.find(params[:label_id])
    elsif params[:site_mapping_id]
      ml = MappingLabel.new()
      ml.site_mapping_id = params[:site_mapping_id]
    end
    if ml
      ml.name = params[:label_name]
      ml.value = params[:label_value]
      if ml.save
        site_mapping = SiteMapping.find(ml.site_mapping_id)
        @mapping_labels = site_mapping.mapping_labels
        @mapping_id = ml.site_mapping_id
        render :partial => 'mapping_labels'
      else
        render :text => 'unable to save label' #TODO: Use Ajax :update to display, re-display label list.
      end
    else
      render :text => 'unable to save label' #TODO: Use Ajax :update to display error, re-display label list.
    end
  end

  def delete_site_mapping_label
    #Delete from parents? Childern?
    #What if the same label is set on multiple ansestors?
    if MappingLabel.delete(params[:label_id]) > 0
      render :nothing => true 
    else
      render :text => 'Unable to delete label' 
    end
  end

  def new_document
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:mapping_id]
    
    @chunk = Chunk.new
    @chunk_version = ChunkVersion.new
  end
  
  def store_document
    mime_type = MimeType.find_by_file_name(params[:site_mapping][:path_segment])
  
    chunk = Chunk.new(params[:chunk])
    chunk.live_version = 1
    chunk.mime_type = mime_type
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
    version = @chunk.chunk_versions.create(params[:chunk_version])
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
  
  def new_folder
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:mapping_id]
  end
  
  def store_folder
    site_mapping = SiteMapping.new(params[:site_mapping])
    site_mapping.lft = 0
    site_mapping.rgt = 0
    site_mapping.depth = 0
    site_mapping.parent_id = 0 unless site_mapping.parent_id
    site_mapping.save
    
    redirect_to :action => 'index'
  end
  
  def edit_folder
    @site_mapping = SiteMapping.find(params[:mapping_id])
  end
  
  def update_folder
    @site_mapping = SiteMapping.find(params[:site_mapping_id])
    @site_mapping.update_attributes(params[:site_mapping])
    @site_mapping.save
    
    redirect_to :action => 'index'
  end
  
  # See 
  #  * [http://wiki.rubyonrails.org/rails/pages/HowtoUploadFiles HowtoUploadFiles]
  #  * [http://wiki.rubyonrails.org/rails/pages/Upload+Progress+Bar Upload Progress Bar]
  #  * [http://manuals.rubyonrails.com/read/chapter/56 Sending and receiving files]
  #  * http://api.rubyonrails.com/classes/ActionController/Streaming.html send_data API]
  #  * [http://scottraymond.net/articles/2005/07/05/caching-images-in-rails Caching]
  def upload
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:mapping_id]
    
    @chunk = Chunk.new
    @chunk_version = ChunkVersion.new
  end
  
  def store_uploaded
    file_name = params['chunk_version']['tmp_file'].original_filename.gsub(/[^a-zA-Z0-9.]/, '_') # This makes sure filenames are sane
    mime_type = MimeType.find_by_file_name(file_name)
    @params['chunk_version']['content'] = @params['chunk_version']['tmp_file'].read
    @params['chunk_version'].delete('tmp_file')
    
    chunk = Chunk.new(params[:chunk])
    chunk.live_version = 1
    chunk.mime_type_id = mime_type.id
    chunk.save
    
    chunk_version = chunk.chunk_versions.create(params[:chunk_version])
    chunk_version.version = 1
    chunk_version.save
    
    site_mapping = SiteMapping.new(params[:site_mapping])
    site_mapping.path_segment = file_name
    site_mapping.chunk_id = chunk.id
    site_mapping.lft = 0
    site_mapping.rgt = 0
    site_mapping.depth = 0
    site_mapping.parent_id = 0 unless site_mapping.parent_id
    site_mapping.save
    
    redirect_to :action => 'index'
  end
end
