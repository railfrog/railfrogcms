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
  $RF_INTERANAL_TAG = "rf-internal"
  
  def self.load_definition(file)
    site_definition = YAML::load(File.open( file ))
    
    Dir.chdir("site/")
    get_pages(site_definition["site"], SiteMapping.find_or_create_root)
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

        puts "*PATH: " + path_segment
	if path_segment == $RF_LABELS_TAG || path_segment == $RF_INTERANAL_TAG then

	  puts "*NEXT"
          next
	end

        # Check whether such SiteMapping already exists
        sm = SiteMapping.find_or_create_by_parent_and_path_segment(parent_sitemapping, path_segment) 
	load_labels(page, sm)
	is_internal(page, sm)

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
    end
  end

  def self.is_internal(node, site_mapping)
    puts "      checking whether site_mapping '#{site_mapping.full_path}' is internal"

    if node.class == Hash && node.has_key?($RF_INTERANAL_TAG) then
      site_mapping.is_internal = node[$RF_INTERANAL_TAG]
      site_mapping.save!
    else
      is_parent_internal(site_mapping)   
    end
    
  end

  def self.load_file_content(file)
    File.new(file).binmode.read
  end

  def self.is_parent_internal(site_mapping)
    parent = SiteMapping.find(site_mapping.parent_id)
    if parent.is_internal then
      site_mapping.is_internal = true
      site_mapping.save!
    end
  end
end
