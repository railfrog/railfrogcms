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
  end

  def self.load_content_chunks(path, parent_sitemapping)
    parent_id = parent_sitemapping ? parent_sitemapping.id : 0
    unless path == "" then
      path_segment = path.chomp('/').split('/').last
      sm = SiteMapping.create :path_segment => path_segment, :parent_id => parent_id, :depth => 0, :lft => 0, :rgt => 0, :root_id => 0
      sm.save
    end
    
    puts "Loading chunks from the " + path
    Dir.glob(path + '*').each {|filename| 
      if File.directory?(filename) then
        puts filename + " is a dir"
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
    Dir.glob('*').each {|file| 
      load_content_chunk(file)
    }
  end
  
  def self.load_layout_chunk(file)
    filename = File.basename(file)
    content = IO.read(file)
    
    c = Chunk.create :description => filename, :live_version => 1
    c.save
    c.chunk_versions.create :version => 1, :base_version => 0, :content => content
  end

end
