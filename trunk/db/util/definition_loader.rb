require 'yaml'
require File.dirname(__FILE__) + '/../../config/environment'
require File.dirname(__FILE__) + '/../../app/models/chunk'

class SiteDefinitionLoader
  
  def self.load_definition(file)
    site_definition = YAML::load(File.open( file ))
    
    Dir.chdir("layouts/")
    loaded_layouts = load_layouts site_definition["layouts"]
    
    Dir.chdir("../pages/")
    loaded_chunks = {}
    get_pages(site_definition["pages"], loaded_chunks, nil)
    
    Dir.chdir("../")
    return loaded_layouts, loaded_chunks
  end
  
  def self.load_layouts(node)
    loaded_layouts = {}
    
    # loading layouts
    node.each {|layout| 
      layout.each {|layout_name, value|
        if value['path'] then
          content = load_content(value['path'])
        elsif value['content']
          content = value['content']
        else 
          next
        end
        
        puts "  Creating layout chunk #{layout_name}"
        c = create_chunk(layout_name, content)
        loaded_layouts[c.description] = c
      }
    }
    
    loaded_layouts
  end
  
  def self.get_pages(node, loaded_chunks, parent_sitemapping) 
    parent_id = parent_sitemapping ? parent_sitemapping.id : 0
    
    node.each { |path_segment, page|
      
      if page['path'] || page['content'] then
        if page['path'] then # load file from the path
          content = load_content(page['path'])
        else
          content = page['content']
        end
        
        chunk, sm = create_content_chunk(path_segment, parent_sitemapping, content)
        
        # Loading labels
        # labels:
        #   layout: "chunk:1"
        #   active_menu_item: "1" 
        if page['labels'] then
          page['labels'].each { |name, value|
            MappingLabel.create :site_mapping_id => sm.id, :name => name, :value => value
          }
        end
          
        loaded_chunks[sm.full_path] = chunk
      else # dir
        sm = SiteMapping.create :path_segment => path_segment, :parent_id => parent_id, :depth => 0, :lft => 0, :rgt => 0, :root_id => 0
        sm.save
      
        get_pages(page, loaded_chunks, sm)
      end
    }
  end
  
  def self.create_content_chunk(filename, parent_sitemapping, content)
    puts "  Creating content chunk filename: #{filename} #{parent_sitemapping}"
    parent_id = parent_sitemapping ? parent_sitemapping.id : 0
    mime_type = MimeType.find_by_file_name(filename)
    c = create_chunk(filename, content, mime_type.id);

    sm = SiteMapping.create :path_segment => filename, :parent_id => parent_id, :depth => 0, :lft => 0, :rgt => 0, :root_id => 0, :chunk_id => c.id
    sm.save

    return c, sm
  end
  
  def self.create_chunk(description, content, mime_type_id = nil)
    c = Chunk.create :description => description, :live_version => 1, :mime_type_id => mime_type_id
    c.save

    c.chunk_versions.create :version => 1, :base_version => 0, :content => content
   
    return c
  end
  
  def self.load_content(file)
    File.new(file).binmode.read
  end
end
