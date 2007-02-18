class Chunk < ActiveRecord::Base
  has_many :chunk_versions
  has_one :latest_version,
          :class_name => 'ChunkVersion',
          :order => 'created_at DESC'
  has_many :pages
  has_many :containers, :through => :pages
  
  def self.find_version(id, version = nil)
    chunk = find(id)
    version = chunk.live_version unless version 
    chunk.chunk_versions.find(:first, :conditions => ["version = ?", version])
  end
end
