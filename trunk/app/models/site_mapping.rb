class SiteMapping < ActiveRecord::Base
  belongs_to :chunk
  
  def self.find_chunk(path)
    m = SiteMapping.find(:first, :conditions => ["path_segment = ?", path])
    Chunk.find_version(m.chunk_id, m.version)
  end
end
