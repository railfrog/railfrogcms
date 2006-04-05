require File.dirname(__FILE__) + '/../../config/environment'
require File.dirname(__FILE__) + '/definition_loader'

class SiteLoader
  def self.load_site(site_name)
  
    puts "Loading site content from the site.yml"
    Dir.chdir("db/sites/#{site_name}/")
    loaded_layouts, loaded_chunks = SiteDefinitionLoader.load_definition 'site.yml'
  
    puts "Loading site content from filesystem"
    Dir.chdir("pages/")
    load_content_chunks("", nil, loaded_chunks)

    Dir.chdir("../layouts/")
    load_layout_chunks(loaded_layouts)
  end

  def self.load_content_chunks(path, parent_sitemapping, loaded_chunks)
    puts " Loading pages"
    parent_id = parent_sitemapping ? parent_sitemapping.id : 0
    unless path == "" then
      path_segment = path.chomp('/').split('/').last
      sm = SiteMapping.create :path_segment => path_segment, :parent_id => parent_id, :depth => 0, :lft => 0, :rgt => 0, :root_id => 0
      sm.save
    end
    
    puts " Loading chunks from the " + path
    Dir.glob(path + '*').each {|filename| 
      if File.directory?(filename) then
        STDERR.puts filename + " is a dir"
        load_content_chunks filename + '/', sm, loaded_chunks
      else
        load_content_chunk(filename, sm) unless loaded_chunks.has_key?(filename)
      end
    }
  end

  def self.load_content_chunk(file, parent_sitemapping)
    filename = File.basename(file)
    content = SiteDefinitionLoader.load_content(file)
    SiteDefinitionLoader.create_content_chunk(filename, parent_sitemapping, content)
  end

  def self.load_layout_chunks(loaded_layouts)
    puts " Loading layouts"
    Dir.glob('*').each {|file| 
      load_layout_chunk(file) unless loaded_layouts.has_key?(file)
    }
  end
  
  def self.load_layout_chunk(file)
    puts "  Creating layout chunk #{layout_name}"
    filename = File.basename(file)
    content = SiteDefinitionLoader.load_content(filename)
    SiteDefinitionLoader.create_chunk(filename, content);
  end
end

