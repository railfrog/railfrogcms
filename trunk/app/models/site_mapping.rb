class SiteMapping < ActiveRecord::Base
  #acts_as_threaded
  belongs_to :chunk
  
  validates_uniqueness_of :path_segment, :scope => "parent_id"
  
  def self.find_chunk_and_layout(path)
    if path.size == 0 then
      m = SiteMapping.find(:first, :conditions => "path_segment = ''")
    else 
      path_segment = path[path.size - 1]
      depth = path.size
      
      m = SiteMapping.find("SQL goes here")
    end
    
    c = Chunk.find_version(m.chunk_id, m.version) if m
    l = "default"
    return c, l
  end
  
end
