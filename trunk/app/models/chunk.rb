class Chunk < ActiveRecord::Base
  has_many :site_mappings
  has_many :chunk_versions, :order => 'version', :dependent => :destroy
  belongs_to :mime_type

  def self.create_chunk(description, content, mime_type_id = nil)
    c = Chunk.create :description => description, :live_version => 1, :mime_type_id => mime_type_id
    c.save

    c.chunk_versions.create :version => 1, :base_version => 0, :content => content

    c
  end

  def self.find_or_create_by_site_mapping_and_content(site_mapping, content)

    if site_mapping.chunk_id then
      c = Chunk.find(site_mapping.chunk_id)
      next_version = ChunkVersion.next_version(c.id)
      c.live_version = next_version
    else
      filename = site_mapping.path_segment
      mime_type = MimeType.find_by_file_name(filename)

      c = Chunk.create :description => filename, :live_version => 1, :mime_type_id => mime_type.id
      c.save
      site_mapping.chunk_id = c.id 
      site_mapping.save

      next_version = 1
    end

    c.chunk_versions.create :version => next_version, :base_version => 0, :content => content

    c
  end

  def find_version(version = nil)
    Chunk.find_version({:id => self.id, :version => version })
  end

  # available options are: :id, :path, :version
  def self.find_version(options)
    if id = options[:id] then
      chunk = find(id)
    elsif path = options[:path] then
      chunk = SiteMapping.find_mapping(path.split('/')).chunk
    else
      return nil
    end

    version = options[:version] ? options[:version] : chunk.live_version
    if version == 'LATEST' then
      version = ChunkVersion.last_version(chunk.id)
    end

    chunk.chunk_versions.find(:first, :conditions => ["version = ?", version])
  end
end
