module Railfrog
  class AdminController < BaseController
    upload_status_for :store_uploaded, :store_uploaded_version
    
    ################################################################################################# Routed Actions
    
    def index
      # redirect to the default admin action
      redirect_to :action => :explore
    end
    
    def explore
      # TODO: sort SiteMappings alphabetically within tree
      
      # if we were given a SiteMapping id, retrieve it, otherwise default to the root SiteMapping
      @site_mapping = params[:id].nil? ? SiteMapping.root : SiteMapping.find(params[:id])
      
      if @site_mapping.folder?
        # this SiteMapping is a folder, so we can show its info
        @folder = @site_mapping
      else
        # this SiteMapping is not a folder, so we show its parent's info
        @folder = @site_mapping.parent
        
        # get the chunk this SiteMapping refers to
        @chunk = @site_mapping.chunk
        # get the mime type of this chunk
        @mime_type = @chunk.mime_type
        # get all the versions of this chunk
        @chunk_versions = ChunkVersion.find(:all,
                                            :conditions => ["chunk_id = ?", @chunk.id],
                                            :order => "version DESC")
      end
      
      # get the full path for this SiteMapping
      @full_path = @site_mapping.full_path
    end
    
    def edit_chunk
      @source = true if params[:source]
      @site_mapping = SiteMapping.find(params[:id])
      @chunk_version = @old_chunk_version = ChunkVersion.find(params[:version])
      @chunk = @chunk_version.chunk
    end
    
    ############################################################################################# Non-Routed Actions
    
    def new_folder
      @site_mapping = SiteMapping.new
      @site_mapping.parent_id = params[:site_mapping_id]
      
      render :partial => 'explore_block_new_folder'
    end
    
    def create_folder
      begin
        @site_mapping = SiteMapping.create(params[:site_mapping])
        
        # reload page to refresh changes
        render(:update) { |page| page.redirect_to '' }
      rescue
        render :update do |page|
          page.replace_html 'content-main', :partial => 'new_folder'
        end
      end
    end
    
    def edit_folder
      @site_mapping = SiteMapping.find(params[:site_mapping_id])
      
      render :partial => 'explore_block_edit_folder'
    end
    
    def update_folder
      @site_mapping = SiteMapping.find(params[:site_mapping][:id])
      begin
        @site_mapping.update_attributes(params[:site_mapping])
        render(:update) { |page| page.redirect_to '' }
      rescue
        render(:update) { |page| page.replace_html 'content-main', :partial => 'rename_folder' }
      end
    end
    
    def delete_folder
      site_mapping = SiteMapping.find(params[:site_mapping_id])
      parent_id = site_mapping.parent.id
      
      SiteMapping.destroy(site_mapping.id)
      
      # redirect to exploring this folder's parent
      render(:update) { |page| page.redirect_to :action => :explore, :id => parent_id }
    end
    
    def new_mapping_label
      @mapping_label = MappingLabel.new
      @mapping_label.site_mapping_id = params[:site_mapping_id]
      
      render :partial => 'explore_block_new_mapping_label'
    end
    
    def create_mapping_label
      begin
        @mapping_label = MappingLabel.create(params[:mapping_label])
        flash[:notice] = "The label '#{@mapping_label.name}' has been updated."
        render(:update) { |page| page.redirect_to '' }
      rescue
        render(:update) { |page| page.replace_html 'content-main', :partial => 'explore_block_new_mapping_label' }
      end
    end
    
    def edit_mapping_label
      @mapping_label = MappingLabel.find(params[:mapping_label_id])
      
      render :partial => 'explore_block_edit_mapping_label'
    end
    
    def update_mapping_label
      @mapping_label = MappingLabel.find(params[:mapping_label][:id])
      
      begin
        @mapping_label.update_attributes(params[:mapping_label])
        render(:update) { |page| page.redirect_to '' }
      rescue
        render(:update) { |page| page.replace_html 'content-main', :partial => 'explore_block_edit_mapping_label' }
      end
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
    
    def new_chunk
      @site_mapping = SiteMapping.new
      @site_mapping.parent_id = params[:parent_id]
      @chunk = Chunk.new
      @chunk_version = ChunkVersion.new
      @session[:syntax] = params[:syntax]     # currently markdown or textile - use html if nil
      
      render :partial => 'explore_block_new_chunk'
    end
    
    def create_chunk
      @chunk = Chunk.new(params[:chunk])
      @chunk_version = @chunk.chunk_versions.build(params[:chunk_version])
      @site_mapping = @chunk.site_mappings.build(params[:site_mapping])
      
      begin
        @chunk.live_version = 1
        if @session[:syntax]
          matching_types = MimeType.find_by_class(@session[:syntax])
          @chunk.mime_type = matching_types[0] if matching_types
        else
          @chunk.mime_type = MimeType.find_by_file_name(params[:site_mapping][:path_segment])
        end
        # TODO CHK REMOVE:
        # breakpoint
        @chunk.save!
        render(:update) { |page| page.redirect_to :action => :explore }
      rescue Exception => e
        # TODO CHK remove:
        logger.error e.to_s
        render :update do |page|
          flash[:notice] = 'Error: Unable to save content'
          page.replace_html 'content', :partial => 'explore_block_new_chunk'
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
    
    def put_live
      chunk_version = ChunkVersion.find(params[:chunk_version_id])
      
      chunk = chunk_version.chunk
      chunk.live_version = chunk_version.version
      chunk.save!
      
      chunk_versions = ChunkVersion.find(:all,
                                         :include => :chunk,
                                         :conditions => ["chunk_id = ?", chunk.id],
                                         :order => "version DESC")
  
      site_mapping = SiteMapping.find_by_chunk_id(chunk.id)        # TODO REFACTOR - chunk may have multiple mappings!
      
      # expire the chunk if it was cached
      expire_page :controller => 'site_mapper', :action => 'show_chunk', :path => site_mapping.full_path
      
      render :partial => 'explore_block_chunk_versions', :locals => { :chunk => chunk,
                                                                      :chunk_versions => chunk_versions,
                                                                      :site_mapping => site_mapping }
    end
    
    def delete_chunk
      SiteMapping.destroy(params[:site_mapping_id])
      Chunk.destroy(params[:chunk_id])
      
      redirect_to :action => 'explore'
    end
    
    # Renders the folder tree for the given SiteMapping
    def folder_tree
      render :partial => 'folder_tree', :locals => { :site_mapping => SiteMapping.find(params[:site_mapping_id]) }
    end
  end
end
