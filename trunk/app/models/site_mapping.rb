class SiteMapping < ActiveRecord::Base
  acts_as_threaded
  belongs_to :chunk
  
  validates_uniqueness_of :path_segment, :scope => "parent_id"
  
  def self.find_chunk_and_layout(path)
    c = find_chunk(path)
    l = find_layout(path)
    return c, l
  end
  
  def self.find_chunk(path) 
    # find chunk for given path
    sm = SiteMapping.find_by_sql(construct_find_chunk_sql(path))
    
    # find chunk version
    cv = Chunk.find_version(sm[0].chunk_id, sm[0].version) if sm && sm.size == 1
  end
  
  def self.find_layout(path) 
    layout_ids = SiteMapping.connection.select_all(construct_find_layout_sql(path))
    
    # getting first row (we have only one row). this a hash
    layout_ids = layout_ids[0] 
    return nil unless layout_ids
    
    # Eg we got a hash: 
    # {"sm0_layout_id" => 0, "sm1_layout_id" => nil, "sm2_layout_id" => 2 }
    # and we'd like to create an array 
    # {0 => 0, 1 => nil, 2 => 2}
    ordered_ids = []
    for key in layout_ids.keys
      key.scan(/\d+/) {|new_key| ordered_ids[new_key.to_i] = layout_ids[key]}
    end

    # find layout id for last non null value
    id = ordered_ids.reverse.find {|id| id}
    
    # find layout by id    
    Layout.find(id) if id
  end
  
  protected 
  
  # Constructs SQL query for getting site_mapping leaf.
  # Eg, for path ["products", "cakes", "chocolate_cake.html"]
  # this query will find 'chocolate_cake.html' leaf.
  def self.construct_find_chunk_sql(path)
    
    if path.size > 0 then
      chunk_index = path.size-1
    else
      chunk_index = 0
    end
    "SELECT DISTINCT sm#{chunk_index}.* #{construct_from_and_where_clauses(path)}" 
  end
  
  # Constucts SQL query for getting layout_ids for given path.
  # Eg, for path ["products", "cakes", "chocolate_cake.html"]
  # this query will find 'chocolate_cake.html' leaf.
  def self.construct_find_layout_sql(path)
    layouts_list = ["sm0.layout_id AS sm0_layout_id"]
    for i in 1..(path.size - 1) do
      layouts_list << ", sm#{i}.layout_id AS sm#{i}_layout_id"
    end
    
    "SELECT #{layouts_list.to_s} #{construct_from_and_where_clauses(path)}" 
  end

  # Constructs JOINs and conditions for given path  
  def self.construct_from_and_where_clauses(path)
    joins = ["site_mappings AS sm0"]
    conditions = ["sm0.path_segment LIKE '#{path[0]}'"]
    for i in 1..(path.size - 1) do
      joins << " INNER JOIN site_mappings AS sm#{i} ON sm#{i-1}.id = sm#{i}.parent_id"
      conditions << " AND sm#{i}.path_segment LIKE '#{path[i]}'"
    end
    
    "FROM #{joins.to_s} WHERE #{conditions.to_s}" 
  end
end
