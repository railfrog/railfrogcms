require 'site_mapping'
require 'chunk'
require File.dirname(__FILE__) + '/definition_loader'

class SiteMapping < ActiveRecord::Base
  def set_internal_if_parent_is_internal
    if self.parent_mapping.is_internal
      Railfrog::info "      '#{self.full_path}' is internal because of internal parent"
      self.is_internal = true
      self.save!
    end
  end

  def create_chunk_version(content)
    Chunk.find_or_create_by_site_mapping_and_content(self, content) if self.chunk.nil?
  end
end

class Chunk < ActiveRecord::Base
  def self.find_or_create_by_site_mapping_and_content(site_mapping, content)

    if site_mapping.chunk_id
      c = Chunk.find(site_mapping.chunk_id)
      next_version = ChunkVersion.next_version(c.id)
      c.live_version = next_version
    else
      filename = site_mapping.path_segment
      mime_type = MimeTypeTools.find_by_file_name(filename)

      c = Chunk.create :description => filename, :live_version => 1, :mime_type_str => mime_type.to_s
      c.save
      site_mapping.chunk_id = c.id 
      site_mapping.save

      next_version = 1
    end

    c.chunk_versions.create :version => next_version, :base_version => 0, :content => content, :comments => filename

    c
  end
end

module Railfrog

  #FIXME: Write help for SiteLoader usage
  class SiteLoader

    SITE_YML = 'site.yml'
    SITE_DIR = 'root'
    SKIP_LIST = ['.svn']

    # Loads site content from the file system. If path dir contains site.yml
    # file it will load content according to the site definition from the given YAML file.
    # Otherwise it will load all files from the path.
    def self.load_site(path)
      @@path = path
      raise "There is no such dir #{path}" unless File.directory? path

      Railfrog::info "Loading site from the '#{path}' dir"

      if File.file? File.join(path, SITE_YML)
        SiteDefinitionLoader.load_definition(path, SITE_YML)
        @@path = File.join(@@path, SITE_DIR) if SiteMapping.count > 0
      end

      if File.directory?(@@path)
        Railfrog::info "  Loading files"
        load_files
      end
    end

    private
    def self.load_files(parent = SiteMapping.find_root)
      Dir.foreach(File.join(@@path, parent.full_path)) {|f|
        if f != '.' && f != '..' && !SKIP_LIST.include?(f)
          site_mapping = parent.find_or_create_child({ :path_segment => f })
          if File.directory?(File.join(@@path, site_mapping.full_path))
            load_files site_mapping
          else
            load_file site_mapping
          end
        end
      }
    end

    # Load chunk content from the file. The file name
    # we will get from the SiteMapping
    def self.load_file(site_mapping)
      file = File.join(@@path, site_mapping.full_path)

      Railfrog::info "    loading content of the chunk from file: '#{file}'"
      site_mapping.create_chunk_version(Railfrog::load_file(file))
      site_mapping.set_internal_if_parent_is_internal
    end
  end

  def self.info(message)
    puts message unless RAILS_ENV == 'test'
  end

  def self.load_file(file)
    File.new(file).binmode.read
  end

end
