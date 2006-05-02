require 'pp'
require 'yaml'
require File.dirname(__FILE__) + '/../../config/environment'
require File.dirname(__FILE__) + '/../../app/models/chunk'

# FIXME: write documentation
class SiteDefinitionLoader
	
  # tag name of the labels tag, eg:
  # pages:
  #   rf_labels:
  #     index-page=index.html
  #     layout=chunk:1
  $RF_LABELS_TAG = "rf-labels"
  
  def self.load_definition(file)
    site_definition = YAML::load(File.open( file ))
    
    Dir.chdir("layouts/")
    load_layouts site_definition["layouts"]
    
    Dir.chdir("../pages/")
    get_pages(site_definition["pages"], SiteMapping.find_or_create_root)
    
    Dir.chdir("../")
  end
  
  def self.load_layouts(node)
    node.each {|layout| 
      layout.each {|layout_name, value|
        if value['path'] then
          content = load_file_content(value['path'])
        elsif value['content']
          content = value['content']
        else 
          next
        end
        
        puts "    loading layout chunk '#{layout_name}'"
        c = Chunk.create_chunk(layout_name, content)
      }
    }
  end
  
  def self.get_pages(node, parent_sitemapping) 

    node.each { |path_segment, page|

      if page.class == Hash \
          && page.has_key?('path') \
          && page['path'].class == String then # load file from the path

        content = load_file_content(page['path'])

	sm = SiteMapping.find_or_create_by_parent_and_path_segment(parent_sitemapping, path_segment)
        Chunk.find_or_create_by_site_mapping_and_content(sm, content)
        load_labels(page, sm)

      elsif page.class == Hash \
          && page.has_key?('content') \
          && page['content'].class == String # load content of the chunk from the inline value

        content = page['content']

	sm = SiteMapping.find_or_create_by_parent_and_path_segment(parent_sitemapping, path_segment)
        Chunk.find_or_create_by_site_mapping_and_content(sm, content)
        load_labels(page, sm)
	
      elsif page.class == Hash \
	  && path_segment == $RF_LABELS_TAG \
	  && parent_sitemapping.full_path == '' then # root labels
        load_labels({$RF_LABELS_TAG => page}, parent_sitemapping)
      else # dir
	if path_segment == $RF_LABELS_TAG then
          next
	end

        # Check whether such SiteMapping already exists
        sm = SiteMapping.find_or_create_by_parent_and_path_segment(parent_sitemapping, path_segment) 
	load_labels(page, sm)

        get_pages(page, sm)
      end
    }
  end

  # Loading labels
  # rf-labels:
  #   layout: "chunk:1"
  #   active_menu_item: "1" 
  def self.load_labels(node, site_mapping)
    puts "      loading labels for '#{site_mapping.full_path}' path"
    if node.class == Hash && node.has_key?($RF_LABELS_TAG) then
      node[$RF_LABELS_TAG].each { |name, value|
        site_mapping.mapping_labels.create :name => name, :value => value
      }
    else 
      puts "-------"
      puts " ERROR: unable to get labels for path '#{site_mapping.full_path}' from"
      pp node
      puts "-------"
    end
  end
  
  def self.load_file_content(file)
    File.new(file).binmode.read
  end

end
