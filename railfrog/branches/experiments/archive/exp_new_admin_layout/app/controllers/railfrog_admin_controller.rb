require 'pp'

class RailfrogAdminController < ApplicationController
  before_filter :ensure_logged_in

  upload_status_for :store_uploaded, :store_uploaded_version

  layout 'admin'
  
  @@default_page_heading = 'RailFrog Control Panel'

  def index
    # redirect to the default admin action
    redirect_to :action => :dashboard
  end


  def dashboard
    @page_heading = @@default_page_heading

    # TODO: dashboard stats'n'stuff
  end


  def explore
    @page_heading = @@default_page_heading
  
    # TODO: sort SiteMappings alphabetically within tree

    # if we were given a SiteMapping id, retrieve it
    unless params[:id].nil?
      @site_mapping = SiteMapping.find(params[:id])
    # if we weren't given a SiteMapping id, default to the root SiteMapping
    else
      @site_mapping = SiteMapping.find_by_parent_id(0)
    end

    # If the SiteMapping is a folder, we can list it. If it is a chunk, we list its parent folder.
    @folder = @site_mapping.chunk.nil? ? @site_mapping : SiteMapping.find(@site_mapping.parent_id)

    # get the full path for this SiteMapping
    @full_path = @site_mapping.full_path
    
    unless @site_mapping.chunk.nil?
      # get the chunk this SiteMapping refers to
      @chunk = @site_mapping.chunk
      # get the mime type of this chunk
      # TODO: what if someone uploads a new version with a different mime type? is it possible?
      @mime_type = @chunk.mime_type
      # get all the versions of this chunk
      @chunk_versions = ChunkVersion.find(:all,
                                          :conditions => ["chunk_id = ?", @chunk.id],
                                          :order => "version DESC")
    end


    # TODO: why do we need this?
    # @site_mappings = SiteMapping.get_all_tree.inject({}) do |hash, site_mapping|
    #   (hash[site_mapping.parent_id] ||= []) << site_mapping
    #   hash
    # end
  end


  def edit_chunk
    @page_heading = @@default_page_heading

    @source = true if params[:source]
    @site_mapping = SiteMapping.find(params[:id])
    @chunk_version = @old_chunk_version = ChunkVersion.find(params[:version])
    @chunk = @chunk_version.chunk
  end


  def settings
    @page_heading = @@default_page_heading
  end


  def users
    @page_heading = @@default_page_heading
  end


  def plugins
    @page_heading = @@default_page_heading
  end

  ###############################################################################
  ###############################################################################
  ###############################################################################


  # TODO: Please look at how I did create_or_edit_mapping_label and tell me if you would like them all to be like this (it would combine the following 4 folder methods into 1) -dr_nailz
  def new_folder
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:site_mapping_id]

    render :partial => 'explore_block_new_folder'
  end


  def create_folder
    begin
      @site_mapping = SiteMapping.create(params[:site_mapping])
      render :update do |page|
        page.redirect_to :action => 'index'
      end
    rescue
      render :update do |page|
        page.replace_html 'content-main', :partial => 'new_folder'
      end
    end
  end


  def rename_folder
    @site_mapping = SiteMapping.find(params[:site_mapping_id])

    render :update do |page|
      page.replace_html 'content-main', :partial => 'rename_folder'
    end
  end


  def update_folder
    @site_mapping = SiteMapping.find(params[:site_mapping][:id])
    begin
      @site_mapping.update_attributes(params[:site_mapping])
      render :update do |page|
        page.redirect_to ''
      end
    rescue
      render :update do |page|
        page.replace_html 'content-main', :partial => 'rename_folder'
      end
    end
  end


  def delete_folder
    SiteMapping.destroy_tree(params[:site_mapping_id])

    # reload the admin page to update folders
    render :update do |page|
      page.redirect_to ''
    end
  end


  def create_or_edit_mapping_label
    # editing the given mapping label
    if params[:mapping_label_id]
      @mapping_label = MappingLabel.find(params[:mapping_label_id])
    # creating a mapping label for the given SiteMapping id
    elsif params[:site_mapping_id]
      @mapping_label = MappingLabel.new
      @mapping_label.site_mapping_id = params[:site_mapping_id]
    # posting back a mapping label to create or edit
    elsif params[:commit]
      @mapping_label = MappingLabel.new

      @mapping_label.site_mapping_id = params[:mapping_label][:site_mapping_id]
      @mapping_label.name = params[:mapping_label][:name]
      @mapping_label.value = params[:mapping_label][:value]

      if @mapping_label.save
        # give the user feedback
        flash[:notice] = "The label '#{@mapping_label.name}' has been updated."

        render :update do |page|
          # reload the page to refresh
          page.redirect_to ''
        end
        
        return
      else
        # give negative feedback in flash
        flash[:warning] = 'Unable to update label'

        render :update do |page|
          # dynamically update flash
          page.replace_html 'msg-warning', flash[:warning]
        end
      end
    end

    render :partial => 'edit_mapping_label'
  end


  def delete_mapping_label
    # TODO: Delete from parents? Childern?
    # TODO: What if the same label is set on multiple ansestors?
    mapping_label = MappingLabel.find(params[:mapping_label_id])

    if mapping_label.nil?
      # give negative feedback in flash
      flash[:warning] = "Unable to delete label '#{mapping_label.name}'"

      render :update do |page|
        # dynamically update flash
        page.replace_html 'msg-warning', flash[:warning]
      end
    else
      MappingLabel.delete(mapping_label.id)
      
      # give positive feedback in flash
      flash[:notice] = "Label '#{mapping_label.name}' has been deleted"

      render :update do |page|
        # reload the labels block
        page.replace_html 'labels-content', list_labels(mapping_label.site_mapping)
        # dynamically update flash
        page.replace_html 'msg-notice', flash[:notice]
      end
    end
  end

  ###############################################################################

  def new_chunk
    @site_mapping = SiteMapping.new
    @site_mapping.parent_id = params[:parent_id]
    @chunk = Chunk.new
    @chunk_version = ChunkVersion.new
    
    render :partial => 'explore_block_new_chunk'
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

        render :update do |page|
          page.redirect_to :action => 'explore', :id => @site_mapping.id
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
    @site_mapping.parent_id = params[:site_mapping_id]

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
        render :update do |page|
          page.replace_html 'content', :partial => 'new_chunk'
          page.show 'content'
        end
      end
    end
  end


  def upload_new_version
    site_mapping_id = params[:site_mapping_id]
    cv = ChunkVersion.find(params[:chunk_version_id], :include => :chunk)
    @chunk = cv.chunk
    
    render :partial => 'explore_block_upload_version', :locals => { :site_mapping_id => site_mapping_id }
  end


  def store_uploaded_version
    if params['chunk_version']['tmp_file'].nil? then
      render :action => 'upload_new_version'
    else
      file_name = params['chunk_version']['tmp_file'].original_filename.gsub(/[^a-zA-Z0-9.]/, '_') # This makes sure filenames are sane
      mime_type = MimeType.find_by_file_name(file_name)
      @params['chunk_version']['content'] = @params['chunk_version']['tmp_file'].read
      @params['chunk_version'].delete('tmp_file')

      @chunk = Chunk.find(params[:chunk][:id])
      @chunk_version = @chunk.chunk_versions.build(params[:chunk_version])

      begin
        if params[:put][:live] == "1" then
          @chunk.live_version = @chunk_version.next_version
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
    chunk_versions = ChunkVersion.find(:all,
                                       :include => :chunk,
                                       :conditions => ["chunk_id = ?", params[:chunk_id].to_i],
                                       :order => "version DESC")

    site_mapping = SiteMapping.find_by_chunk_id(params[:chunk_id])

    render :partial => 'explore_block_chunk_versions', :locals => { :chunk => chunk_versions[0].chunk,
                                                                    :chunk_versions => chunk_versions,
                                                                    :site_mapping => site_mapping }
  end


  def put_live
    chunk_version = ChunkVersion.find(params[:chunk_version_id])
    
    chunk = chunk_version.chunk
    chunk.live_version = chunk_version.version
    chunk.save!
    
    chunk_versions = ChunkVersion.find(:all,
                                       :include => :chunk,
                                       :conditions => ["chunk_id = ?", chunk.id],
                                       :order => "version DESC")

    site_mapping = SiteMapping.find_by_chunk_id(chunk.id)

    render :partial => 'explore_block_chunk_versions', :locals => { :chunk => chunk,
                                                                    :chunk_versions => chunk_versions,
                                                                    :site_mapping => site_mapping }
  end


  def delete_chunk
    SiteMapping.destroy(params[:site_mapping_id])
    Chunk.destroy(params[:chunk_id])
    
    redirect_to :action => 'explore'
  end

end
