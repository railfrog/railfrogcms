require 'pp'

# FIXME: direct inserting values to queries
class SiteMapping < ActiveRecord::Base
  # the root folder is empty string
  $ROOT_DIR = ''

  acts_as_threaded
  belongs_to :chunk
  has_many :mapping_labels, :dependent => :destroy

  validates_uniqueness_of :path_segment, :scope => "parent_id"

  def self.get_all_tree
    tree = SiteMapping.find(:all, :order => 'root_id, lft')

    if tree.size == 0 then # the DB is empty
      tree << SiteMapping.find_or_create_root
    end

    tree
  end

  def self.find_or_create_root
    SiteMapping.find_or_create_by_path_segment($ROOT_DIR)
  end

  def self.find_or_create_by_parent_and_path_segment(parent, path_segment)
    sm = SiteMapping.find_by_parent_id_and_path_segment(parent.id, path_segment)

    unless sm then
      sm = SiteMapping.create :path_segment => path_segment, :parent_id => parent.id, :depth => 0, :lft => 0, :rgt => 0, :root_id => 0
    end

    sm
  end

  def full_path
    path_segments = SiteMapping.connection.select_all(construct_find_path_segments_sql)

    # getting first row (we have only one row). this is a hash
    path_segments = path_segments[0] 
    return nil unless path_segments

    # Eg we got a hash: 
    # {"sm0_path_segment" => 'products', "sm1_path_segment" => 'cakes', "sm2_path_segments" => 'chocolate_cake.html' }
    # and we'd like to create an array 
    # {0 => 'products', 1 => 'cakes', 2 => 'chocolate_cake.html'}
    path = []
    for key in path_segments.keys
      key.scan(/\d+/) {|new_key| path[new_key.to_i] = path_segments[key]}
    end

    path.join("/")
  end

  def self.find_chunk_and_mapping_labels(path, version = nil, external_only = false)
    path.insert(0, $ROOT_DIR) unless path[0] == $ROOT_DIR

    c = find_chunk(path, version, external_only)
    ml = find_mapping_labels(path)

    return c, ml
  end

  def self.find_chunk(path, version = nil, external_only = false)
    path.insert(0, $ROOT_DIR) unless path[0] == $ROOT_DIR

    # find site_mapping for given path
    sm = find_by_full_path(path, external_only)

    if sm.empty? then
      nil
    else
      # find chunk version
      unless version then
        version = sm[0].version
      end

      Chunk.find_version({:id => sm[0].chunk_id, :version => version})

    end
  end

  # find site_mapping for given path
  def self.find_by_full_path(path, external_only = false)
    path.insert(0, $ROOT_DIR) unless path[0] == $ROOT_DIR 

    sm = SiteMapping.find_by_sql(construct_find_chunk_sql(path, external_only))
  end

  def self.find_mapping_labels(path)
    path.insert(0, $ROOT_DIR) unless path[0] == $ROOT_DIR 

    conditions = [ "(sm.path_segment like '#{path[0]}' AND sm.depth = 0)" ] 

    for i in 1..(path.size - 1) do
      conditions << " OR (sm.path_segment like '#{path[i]}' AND sm.depth = #{i})"
    end

    labels = MappingLabel.find(:all,
      :conditions => conditions.to_s,
      :joins => "AS mp INNER JOIN site_mappings AS sm ON mp.site_mapping_id = sm.id",
      :order => "sm.depth" )

    result = {}
    labels.each {|label| 
      result[label.name] = label.value
    }

    result
  end

  def self.destroy_tree(id)
    #FIXME: Dirty hack - replace delete with destroy. Probably bug in the
    # acts_as_threaded
    SiteMapping.find(id).full_set.each {|sm| SiteMapping.delete(sm.id) }
  end

  protected

  # Constructs SQL query for getting site_mapping leaf.
  # Eg, for path ["products", "cakes", "chocolate_cake.html"]
  # this query will find 'chocolate_cake.html' leaf.
  def self.construct_find_chunk_sql(path, external_only = false)

    if path.size > 0 then
      chunk_index = path.size-1
    else
      chunk_index = 0
    end
    "SELECT DISTINCT sm#{chunk_index}.* #{construct_from_and_where_clauses(path, external_only)}"
  end

  def construct_find_path_segments_sql
    paths = ["sm0.path_segment AS sm0_path_segment"]
    joins = ["site_mappings AS sm0"]
    for i in 1..(self.depth) do
      paths << ", sm#{i}.path_segment AS sm#{i}_path_segment"
      joins << " INNER JOIN site_mappings AS sm#{i} ON sm#{i-1}.id = sm#{i}.parent_id"
    end

    "SELECT #{paths.to_s} FROM #{joins} WHERE sm#{self.depth}.id = #{self.id}" 
  end

  # Constructs JOINs and conditions for given path  
  def self.construct_from_and_where_clauses(path, external_only = false)
    joins = ["site_mappings AS sm0"]
    conditions = ["sm0.path_segment LIKE '#{path[0]}' AND sm0.depth = 0"] 
    i = 0
    for i in 1..(path.size - 1) do
      joins << " INNER JOIN site_mappings AS sm#{i} ON sm#{i-1}.id = sm#{i}.parent_id"
      conditions << " AND sm#{i}.path_segment LIKE '#{path[i]}'"
    end

    if external_only then
      conditions << " AND sm#{i}.is_internal = false"
    end

    "FROM #{joins.to_s} WHERE #{conditions.to_s}" 
  end


end
