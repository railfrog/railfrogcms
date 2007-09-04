require 'pp'

class RailfrogAdminController < ApplicationController
  before_filter :ensure_logged_in

  upload_status_for :store_uploaded, :store_uploaded_version

  layout 'default'

  def index
    @site_mappings = SiteMapping.get_all_tree.inject({}) do |hash, mapping|
      (hash[mapping.parent_id] ||= []) << mapping
      hash
    end
  end

  def show
    if mapping_id = params[:mapping_id] then
      @site_mapping = SiteMapping.find(mapping_id, :include => [:chunk => [:mime_type]])
    else
      @site_mapping = SiteMapping.find_or_create_root
    end

    @file_name = @site_mapping.full_path

    if @site_mapping.chunk then
      @chunk = @site_mapping.chunk
      @chunk_version = @chunk.find_version

      render :update do |page|
        page.replace_html 'summary', :partial => 'chunk_summary'
        page.replace_html 'chunk_version_summary', :partial => 'chunk_version_summary'
        page.replace_html 'context_menu', :partial => 'chunk_actions'
        page.replace_html 'content', :partial => 'chunk_content',
          :locals => { :file_name => @file_name, :mime_type => @chunk.mime_type.mime_type }
        page.show 'chunk_version_summary'
        page.show 'content'
      end
    else
      render :update do |page|
        page.replace_html 'summary', :partial => 'folder_summary',
          :locals => { :file_name => @file_name.empty? ? '/' : @file_name }
        page.replace_html 'context_menu', :partial => 'folder_actions',
          :locals => { :site_mapping => @site_mapping }
        page.hide 'chunk_version_summary'
        page.hide 'content'
      end
    end
  end

  def new_folder
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:parent_id]

    render :update do |page|
      page.replace_html 'content', :partial => 'new_folder'
      page.show 'content'
    end
  end

  def create_folder
    begin
      @site_mapping = SiteMapping.create(params[:site_mapping])
      render :update do |page|
        page.redirect_to :action => 'index'
      end
    rescue
      render :update do |page|
        page.replace_html 'content', :partial => 'new_folder'
        page.show 'content'
      end
    end
  end

  def rename_folder
    @site_mapping = SiteMapping.find(params[:id])

    render :update do |page|
      page.replace_html 'content', :partial => 'rename_folder'
      page.show 'content'
    end
  end

  def update_folder
    @site_mapping = SiteMapping.find(params[:site_mapping][:id])
    begin
      @site_mapping.update_attributes(params[:site_mapping])
      logger.info @site_mapping

      render :update do |page|
        page.redirect_to :action => 'index'
      end
    rescue
      render :update do |page|
        page.replace_html 'content', :partial => 'rename_folder'
        page.show 'content'
      end
    end
  end

  def show_labels
    @mapping_id = params[:site_mapping_id]
    @mapping_labels = MappingLabel.find_all_by_site_mapping_id(@mapping_id)

    render :update do |page|
      page.replace_html 'content', :partial => 'mapping_labels',
        :locals => { :mapping_labels => @mapping_labels, :mapping_id => @mapping_id }
      page.show 'content'
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

  def delete_folder
    SiteMapping.destroy_tree(params[:mapping_id])

    render :update do |page|
      page.redirect_to :action => 'index'
    end
  end

  ###############################################################################

  def new_chunk
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:parent_id]
    @chunk = Chunk.new
    @chunk_version = ChunkVersion.new
    @use_xinha_editor = true

    render :update do |page|
      page.replace_html 'content', :partial => 'new_chunk'
      page << XINHA_RUNNER_SCRIPT
      page.show 'content'
    end
  end

  def create_chunk
    @chunk = Chunk.new(params[:chunk])
    @chunk_version = @chunk.chunk_versions.build(params[:chunk_version])
    @site_mapping = @chunk.site_mappings.build(params[:site_mapping])

    begin
      @chunk.live_version = 1
      @chunk.mime_type = MimeType.find_by_file_name(params[:site_mapping][:path_segment])
      @chunk.save!
      render :update do |page|
        page.redirect_to :action => 'index'
      end
    rescue
      render :update do |page|
        page.replace_html 'content', :partial => 'new_chunk'
        page.show 'content'
      end
    end
  end

  def edit_chunk
    @use_xinha_editor = params[:source] ? false : true
    @site_mapping = SiteMapping.find(params[:site_mapping_id])
    @chunk_version = @old_chunk_version = ChunkVersion.find(params[:chunk_version_id])
    @chunk = @chunk_version.chunk

    render :update do |page|
      page.replace_html 'content', :partial => 'edit_chunk'

      if @use_xinha_editor
        page << XINHA_RUNNER_SCRIPT
      end

      page.show 'content'
    end
  end

  def update_chunk
    @site_mapping = SiteMapping.find(params[:site_mapping][:id])
    @old_chunk_version = ChunkVersion.find(params[:old_chunk_version][:id])
    @chunk = @old_chunk_version.chunk
    @chunk_version = @chunk.chunk_versions.build(params[:chunk_version])

    begin
      Chunk.transaction do
        @chunk.attributes = params[:chunk]
        @site_mapping.attributes = params[:site_mapping]

        @chunk_version.base_version = @old_chunk_version.version

        if params[:put][:live] == "1" then
          @chunk.live_version = @chunk_version.next_version
        end

        @chunk.save!
        @site_mapping.save!

        expire @site_mapping

        render :update do |page|
          page.redirect_to :action => 'index'
        end
      end
    rescue
      render :update do |page|
        page.replace_html 'content', :partial => 'edit_chunk'
        page.show 'content'
      end
    end
  end

  # See
  #  * [http://wiki.rubyonrails.org/rails/pages/HowtoUploadFiles HowtoUploadFiles]
  #  * [http://wiki.rubyonrails.org/rails/pages/Upload+Progress+Bar Upload Progress Bar]
  #  * [http://manuals.rubyonrails.com/read/chapter/56 Sending and receiving files]
  #  * http://api.rubyonrails.com/classes/ActionController/Streaming.html send_data API]
  #  * [http://scottraymond.net/articles/2005/07/05/caching-images-in-rails Caching]
  def upload_file
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:mapping_id]

    @chunk = Chunk.new
    @chunk_version = ChunkVersion.new

    render :update do |page|
      page.replace_html 'content', :partial => 'upload'
      page.show 'content'
    end
  end

  def store_uploaded
    if params['chunk_version']['tmp_file'].nil? then
      render :action => 'upload'
    else
      file_name = params['chunk_version']['tmp_file'].original_filename.gsub(/[^a-zA-Z0-9.]/, '_') # This makes sure filenames are sane
      mime_type = MimeType.find_by_file_name(file_name)
      params['chunk_version']['content'] = params['chunk_version']['tmp_file'].read
      params['chunk_version'].delete('tmp_file')

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
        render :update do |page|
          page.replace_html 'content', :partial => 'new_chunk'
          page.show 'content'
        end
      end
    end
  end

  def upload_new_version
    cv = ChunkVersion.find(params[:chunk_version_id], :include => :chunk)
    @chunk = cv.chunk
    @site_mapping = SiteMapping.find(params[:mapping_id])

    render :update do |page|
      page.replace_html 'content', :partial => 'upload_new_version'
      page.show 'content'
    end
  end

  def store_uploaded_version
    if params['chunk_version']['tmp_file'].nil? then
      render :action => 'upload_new_version'
    else
      file_name = params['chunk_version']['tmp_file'].original_filename.gsub(/[^a-zA-Z0-9.]/, '_') # This makes sure filenames are sane
      mime_type = MimeType.find_by_file_name(file_name)
      params['chunk_version']['content'] = params['chunk_version']['tmp_file'].read
      params['chunk_version'].delete('tmp_file')

      @chunk = Chunk.find(params[:chunk][:id])
      @chunk_version = @chunk.chunk_versions.build(params[:chunk_version])

      begin
        if params[:put][:live] == "1" then
          @chunk.live_version = @chunk_version.next_version
          expire SiteMapping.find(params[:site_mapping][:id])
        end

        @chunk.mime_type_id = mime_type.id
        @chunk.save!


        redirect_to :action => 'index'
      rescue
        render :update do |page|
          page.replace_html 'content', :partial => 'new_chunk'
          page.show 'content'
        end
      end
    end
  end

  def show_versions
    cv = ChunkVersion.find(:all,
      :include => :chunk,
      :conditions => ["chunk_id = ?", params[:chunk_id].to_i],
      :order => "version DESC")

    render :update do |page|
      page.replace_html 'content', :partial => 'chunk_versions',
        :locals => { :chunk => cv[0].chunk, :chunk_versions => cv,
	  :mapping_id => params[:mapping_id]}
    end
  end

  def put_live
    c = Chunk.find(params[:chunk_id],
      :include => :chunk_versions,
      :order => "chunk_versions.version DESC" )
    c.live_version = params[:version]
    c.save!
    chunk_versions = c.chunk_versions

    @chunk_version = c.find_version

    expire SiteMapping.find(params[:mapping_id])

    render :update do |page|
      page.replace_html 'chunk_version_summary', :partial => 'chunk_version_summary'
      page.replace_html 'content', :partial => 'chunk_versions',
        :locals => { :chunk => c, :chunk_versions => chunk_versions }
    end
  end

  def delete_chunk
    Chunk.destroy(params[:chunk_id])
    sm = SiteMapping.find(params[:mapping_id])
    expire sm
    sm.destroy
    render :update do |page|
      page.redirect_to :action => "index"
    end
  end

  private
  def expire(sm)
    logger.info "Expiring #{sm.full_path}"
    expire_page :controller => 'site_mapper',
      :action => 'show_chunk',
      :path => sm.full_path.split('/')
  end
end
