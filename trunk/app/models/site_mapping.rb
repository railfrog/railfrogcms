class SiteMapping < ActiveRecord::Base
  # the root folder is empty string
  ROOT_DIR = ''
  FILE_SEPARATOR = '/'
  
  acts_as_nested_set

  belongs_to :chunk
  has_many :mapping_labels, :dependent => :destroy
  belongs_to :parent_mapping,
    :class_name => "SiteMapping",
    :foreign_key => "parent_id",
    :include => {:chunk, :mapping_labels}

  validates_uniqueness_of :path_segment, :scope => "parent_id"
  
  def self.find_root
    SiteMapping.find_or_create_by_path_segment_and_parent_id(ROOT_DIR, nil)
  end

  # The only method to create child site_mappings
  def find_or_create_child(path_segment)
    child = find_child path_segment
    unless child
      child = create_child path_segment
    end
    child
  end

  def find_child(path_segment)
    SiteMapping.find_by_parent_id_and_path_segment(self.id, path_segment)
  end

  def create_child(path_segment, is_internal = false)
    child = SiteMapping.new do |sm|
      sm.path_segment = path_segment
      sm.is_internal = is_internal
    end
    if child.save
      child.move_to_child_of self
    end

    # FIXME validates_uniqueness_of :path_segment, :scope => "parent_id" -- is not working 
    # I need to check validness manually and destroy child if invalid
    return child if child.valid?
    child.destroy
    raise ActiveRecord::RecordInvalid.new(child)
  end

  # Finds all site_mappings including labels and chunk for last mappings
  def self.find_mapping(path = [], version = nil, external_only = false)
    
    path.insert(0, ROOT_DIR) unless path[0] == ROOT_DIR

    parent_mappings = nil
    conditions = [] 
    bindings = []
   
    path.reverse.each_with_index do |p, i|
      if i > 1
        parent_mappings = { :parent_mapping => [ parent_mappings, :mapping_labels ] }
        conditions << "parent_mappings_site_mappings_#{i}.path_segment like ?"
      elsif i == 1
        parent_mappings = { :parent_mapping => :mapping_labels }
        conditions << "parent_mappings_site_mappings.path_segment like ?"
      elsif i == 0
        conditions << "site_mappings.path_segment like ?"
      end 
      bindings << p
    end
    
    if path.size > 2
      conditions << "parent_mappings_site_mappings_#{path.size - 1}.parent_id IS NULL"
    elsif path.size == 2
      conditions << "parent_mappings_site_mappings.parent_id IS NULL"
    elsif path.size == 1
      conditions << "site_mappings.parent_id IS NULL"
    end

    if external_only then
      conditions << "site_mappings.is_internal = ?"
      bindings << false
    end
   
    conditions = [conditions.join(' AND ')] + bindings
    
    include = [:chunk, :mapping_labels]
    include << parent_mappings if parent_mappings
    
    m = find(:first,
      :include => include,
      :conditions => conditions)

    # FIXME following code should be refactoried
    if m.nil?
      nil
    else
      # find chunk version
      unless version
        version = m.version
      end

      chunk = Chunk.find_version({:id => m.chunk_id, :version => version})
      labels = process_labels(m)
      
      return chunk, labels, m
    end
  end

  # Returns hash of labels for given site_mapping tree. Overrides ancestor label values.
  def self.process_labels(mapping, labels = {})
    labels = process_labels(mapping.parent_mapping, labels) if mapping.parent_mapping
    mapping.mapping_labels.each {|label| 
      labels[label.name] = label.value
    }
    labels
  end
  
  # UI auxiliry methods
  
  # Full file path: +/+ or +/cakes+ or +/cakes/index.html+
  def full_path
    p = self_and_ancestors.collect{|sm| sm.path_segment }.join(FILE_SEPARATOR)
    p = FILE_SEPARATOR + p unless p =~ /^\// 
    p
  end
  
  def kid_dirs
    SiteMapping.find(:all,
      :conditions => { :parent_id => self.id, :chunk_id => nil },
      :order => "path_segment")
  end

  # Depricated. Used in old UI
  def self.get_all_tree
    tree = SiteMapping.find(:all, :order => 'root_id, lft')

    if tree.size == 0
      tree << SiteMapping.root
    end

    tree
  end
end
