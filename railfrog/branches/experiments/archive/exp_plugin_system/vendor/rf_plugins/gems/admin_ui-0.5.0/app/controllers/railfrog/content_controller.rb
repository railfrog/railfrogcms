class Railfrog::ContentController < Railfrog::BaseController
  def index
    @site_mappings = SiteMapping.get_all_tree.inject({}) do |hash, mapping|
      (hash[mapping.parent_id] ||= []) << mapping
      hash
    end
  end
  
  def show
    disposition = 'inline'
    if params[:mapping_id] then
      @site_mapping = SiteMapping.find(params[:mapping_id])
      @mapping_labels = @site_mapping.mapping_labels #TODO Also look up lables inherited from parents?
      @mapping_id = params[:mapping_id]
      @file_name = @site_mapping.full_path
      if @site_mapping && @site_mapping.chunk then
        @chunk = @site_mapping.chunk
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
        content = render_to_string :partial => 'chunk_content'
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

  def new
    if params[:id] == 'folder'
      new_folder
      render :action => 'new_folder'
    else
      new_chunk
      render :action => 'new_chunk'
    end
  end
  
  def edit
    if params[:id] == 'folder'
      edit_folder
      render :action => 'edit_folder'
    else
      edit_chunk
      render :action => 'edit_chunk'
    end
  end

  def new_chunk
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:parent_id]
    @chunk = Chunk.new
    @chunk_version = ChunkVersion.new
  end
  
  def create_chunk
    @chunk = Chunk.new(params[:chunk])
    @chunk_version = @chunk.chunk_versions.build(params[:chunk_version])
    @site_mapping = @chunk.site_mappings.build(params[:site_mapping])
    
    begin
      @chunk.live_version = 1
      @chunk.mime_type = MimeType.find_by_file_name(params[:site_mapping][:path_segment])
      @chunk.save!
      redirect_to :action => 'index'
    rescue
      render :action => 'new_chunk'
    end
  end
  
  def edit_chunk
    @site_mapping = SiteMapping.find(params[:site_mapping_id])
    @chunk_version = @old_chunk_version = ChunkVersion.find(params[:chunk_version_id])
    @chunk = @chunk_version.chunk
  end
  
  def update_chunk
    @site_mapping = SiteMapping.find(params[:site_mapping_id])
    @old_chunk_version = ChunkVersion.find(params[:old_chunk_version][:id])
    @chunk = @old_chunk_version.chunk
    @chunk_version = @chunk.chunk_versions.build(params[:chunk_version])
    
    begin
      Chunk.transaction do
        @chunk.attributes = params[:chunk]
        @site_mapping.attributes = params[:site_mapping]
        
        @chunk_version.base_version = @old_chunk_version.version
        @chunk.live_version = @chunk_version.next_version #TODO User should select live version
        
        @chunk.save!
        @site_mapping.save!
      end
      redirect_to :action => 'index'
    rescue
      render :action => 'edit_chunk'
    end
  end
  
  def new_folder
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:parent_id]
  end
  
  def create_folder  
    begin
      @site_mapping = SiteMapping.create(params[:site_mapping])
      redirect_to :action => 'index'
    rescue
      render :action => 'new_folder'
    end
  end
  
  def edit_folder
    @site_mapping = SiteMapping.find(params[:site_mapping_id])
  end
  
  def update_folder
    @site_mapping = SiteMapping.find(params[:site_mapping_id])
    begin
      @site_mapping.update_attributes(params[:site_mapping])
      redirect_to :action => 'index'
    rescue
      render :action => 'edit'
    end
  end
  
  # See 
  #  * [http://wiki.rubyonrails.org/rails/pages/HowtoUploadFiles HowtoUploadFiles]
  #  * [http://wiki.rubyonrails.org/rails/pages/Upload+Progress+Bar Upload Progress Bar]
  #  * [http://manuals.rubyonrails.com/read/chapter/56 Sending and receiving files]
  #  * http://api.rubyonrails.com/classes/ActionController/Streaming.html send_data API]
  #  * [http://scottraymond.net/articles/2005/07/05/caching-images-in-rails Caching]
  def upload
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:parent_id]
    
    @chunk = Chunk.new
    @chunk_version = ChunkVersion.new
  end
  
  def store_uploaded
    if params['chunk_version']['tmp_file'].nil?
      render :action => 'upload'
    else 
      file_name = params['chunk_version']['tmp_file'].original_filename.gsub(/[^a-zA-Z0-9.]/, '_') # This makes sure filenames are sane
      mime_type = MimeType.find_by_file_name(file_name)
      @params['chunk_version']['content'] = @params['chunk_version']['tmp_file'].read
      @params['chunk_version'].delete('tmp_file')
      
      @chunk = Chunk.new(params[:chunk])
      @chunk_version = @chunk.chunk_versions.build(params[:chunk_version])
      @site_mapping = @chunk.site_mappings.build(params[:site_mapping])
      
      begin
        @site_mapping.path_segment = file_name
        @chunk.live_version = 1
        @chunk.mime_type_id = mime_type.id
        @chunk.save!
        redirect_to :action => 'index'
      rescue
        render :action => 'upload'
      end
    end
  end
end
