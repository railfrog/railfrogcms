require 'yaml'
require File.dirname(__FILE__) + '/../app/models/chunk'

# Using site.yml allows to
#  * add labels for site mappings,
#  * set is_internal flag to true for internal chunks
#  * load content from the site.yml directly
#  * load content from any place in the file system
class Railfrog::SiteDefinitionLoader

  # tag name of the labels tag, eg:
  # pages:
  #   rf-labels:
  #     index-page=index.html
  #     layout=chunk:1
  RF_LABELS_TAG = "rf-labels"
  RF_INTERANAL_TAG = "rf-internal"

  def self.load_definition(path, file)
    @@path = path
    Railfrog::info "  Loading site content from the #{Railfrog::SiteLoader::SITE_YML}"
    root_node = YAML::load(File.open(File.join(@@path, file )))

    raise "#{Railfrog::SiteLoader::SITE_YML} file is empty" unless root_node
    raise "#{Railfrog::SiteLoader::SITE_YML} file contains no 'root' tag" if root_node["root"].nil?

    parse_definition SiteMapping.find_root, root_node["root"]
  end

  private
  def self.parse_definition(parent_site_mapping, parent_node)
    if parent_site_mapping.root?
      load_labels(parent_site_mapping, parent_node)
    end

    parent_node.each { |path_segment, node|
      next if path_segment == RF_LABELS_TAG || path_segment == RF_INTERANAL_TAG

      site_mapping = parent_site_mapping.find_or_create_child(:path_segment => path_segment)
      Railfrog::info "    processing '#{site_mapping.full_path}'"

      load_labels(site_mapping, node)
      load_is_internal(site_mapping, node)

      content = nil
      if node.class == Hash
        if node.has_key?('path') && node['path'].class == String
          # load file from the path
          content = Railfrog::load_file(File.join(@@path, Railfrog::SiteLoader::SITE_DIR, node['path']))
        elsif node.has_key?('content') && node['content'].class == String
          # load content of the chunk from the inline value
          content = node['content']
        else
          # dir
          parse_definition(site_mapping, node)
        end

        site_mapping.create_chunk_version(content) if content
      end
    }
  end

  # Loading labels
  # rf-labels:
  #   layout: "chunk:1"
  #   active_menu_item: "1" 
  def self.load_labels(site_mapping, node)
    if node.class == Hash && node.has_key?(RF_LABELS_TAG)
      Railfrog::info "      loading labels for '#{site_mapping.full_path}'"
      node[RF_LABELS_TAG].each { |name, value|
        site_mapping.mapping_labels.create(:name => name, :value => value) if MappingLabel.find_by_site_mapping_id_and_name_and_value(site_mapping.id, name, value).nil?
      }
    end
  end

  def self.load_is_internal(site_mapping, node)
    if node.class == Hash && node.has_key?(RF_INTERANAL_TAG)
      Railfrog::info "      '#{site_mapping.full_path}' is internal"
      site_mapping.is_internal = node[RF_INTERANAL_TAG]
      site_mapping.save!
    else
      site_mapping.set_internal_if_parent_is_internal
    end
  end

end
