class Chunk < ActiveRecord::Base
  has_many :site_mappings
  has_many :chunk_versions, :order => 'version', :dependent => :destroy
  has_one :live_chunk_version,
    :class_name => 'ChunkVersion',
    :foreign_key => 'chunk_id', :conditions => 'chunk_versions.version = chunks.live_version'


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
