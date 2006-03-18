class SiteMapping < ActiveRecord::Base
  acts_as_threaded
  belongs_to :chunk
  
  validates_uniqueness_of :path_segment, :scope => "parent_id"
  
  def self.find_chunk_and_layout(path)
    if path.size == 0 then
      puts "SIZE = 0"
      m = SiteMapping.find(:first, :conditions => "path_segment = ''")
    else 
      puts "SIZE = #{path.size}"
      ms = SiteMapping.find_by_sql(construct_sql(path))
      if ms then 
        if ms.size > 0 then 
          m = ms[0] # FIXME: add correct code here
        end
      end
    end
    
    c = Chunk.find_version(m.chunk_id, m.version) if m 
    l = "default"
    return c, l
  end
  
  protected 
  
  # Constuct SQL query for getting site_mapping leaf.
  # Eg, for path ["products", "cakes", "chocolate_cake.html"]
  # this query will find 'chocolate_cake.html' leaf.
  def self.construct_sql(path)
    table = "site_mappings" 
    tbl = "sm"
    pth = path.reverse
    
    joins = ["#{table} #{tbl}0"]
    conditions = ["#{tbl}0.path_segment LIKE '#{pth[0]}'"]
    for i in 1..(pth.size - 1) do
      joins << " INNER JOIN #{table} #{tbl}#{i} ON #{tbl}#{i-1}.parent_id = #{tbl}#{i}.id"
      conditions << " AND #{tbl}#{i}.path_segment LIKE '#{pth[i]}'"
    end
    
    "SELECT DISTINCT sm0.* FROM #{joins.to_s} WHERE #{conditions.to_s}" 
  end
end
