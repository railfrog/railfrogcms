class AddMappingParamsTable < ActiveRecord::Migration
  def self.up
    create_table :mapping_params do |t|
      t.column :site_mapping_id, :integer
      t.column :name,            :string
      t.column :value,           :string
    end  

    remove_column :site_mappings, :layout_id
    drop_table :layouts
    
    load_site "railfrog"
  end

  def self.down
    add_column :site_mappings, :layout_id, :integer
    
    create_table :layouts do |t|
      t.column :name, :string
    end
    
    drop_table :mapping_params
  end

  def self.load_site(site_name)
    Dir.chdir("db/sites/#{site_name}/pages/")
    load_content_chunks "", nil

    Dir.chdir("../layouts/")
    load_layout_chunks
    
    # Adhoc
    # cos we have no UI for mapping_params
    MappingParam.create :site_mapping_id => 1, :name => "layout", :value => "chunk:10"
    MappingParam.create :site_mapping_id => 10, :name => "layout", :value => "chunk:10"
  end

  def self.load_content_chunks(path, parent_sitemapping)
    STDERR.puts "Loading pages"
    parent_id = parent_sitemapping ? parent_sitemapping.id : 0
    unless path == "" then
      path_segment = path.chomp('/').split('/').last
      sm = SiteMapping.create :path_segment => path_segment, :parent_id => parent_id, :depth => 0, :lft => 0, :rgt => 0, :root_id => 0
      sm.save
    end
    
    STDERR.puts "Loading chunks from the " + path
    Dir.glob(path + '*').each {|filename| 
      if File.directory?(filename) then
        STDERR.puts filename + " is a dir"
        load_content_chunks filename + '/', sm
      else
        load_content_chunk(filename, sm)
      end
    }
  end

  def self.load_content_chunk(file, parent_sitemapping)
    filename = File.basename(file)
    content = File.new(file).binmode.read

    parent_id = parent_sitemapping ? parent_sitemapping.id : 0
    sm = SiteMapping.create :path_segment => filename, :parent_id => parent_id, :depth => 0, :lft => 0, :rgt => 0, :root_id => 0

    mime_type = MimeType.find_by_file_name(filename)
    c = Chunk.create :description => filename, :live_version => 1, :mime_type_id => mime_type.id
    c.save
    c.chunk_versions.create :version => 1, :base_version => 0, :content => content
    
    sm.chunk_id = c.id
    sm.save
  end

  def self.load_layout_chunks
    STDERR.puts "Loading layouts"
    Dir.glob('*').each {|file| 
      load_layout_chunk(file)
    }
  end
  
  def self.load_layout_chunk(file)
    filename = File.basename(file)
    content = File.new(file).binmode.read
    
    c = Chunk.create :description => filename, :live_version => 1
    c.save
    c.chunk_versions.create :version => 1, :base_version => 0, :content => content
  end

end
