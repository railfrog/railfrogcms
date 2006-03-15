class SiteMapping < ActiveRecord::Base
  def self.find_chunk(path)
    m = SiteMapping.find(:first, :conditions => ["path_segment = ?", path])
    
    if m.version then
      Chunk.find_version(m.chunk_id, m.version)
    else 
      Chunk.find_live_version(m.chunk_id)
    end
  end
end
