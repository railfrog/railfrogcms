class SiteMapping < ActiveRecord::Base
  # the root folder is empty string
  ROOT_DIR = ''
  FILE_SEPARATOR = '/'

  acts_as_nested_set

  belongs_to :chunk
  has_many :mapping_labels, :dependent => :destroy
  belongs_to :parent_mapping,
    :class_name => "SiteMapping",
    :foreign_key => "parent_id"

  validates_uniqueness_of :path_segment, :scope => "parent_id"

  def self.find_root
    SiteMapping.find_or_create_by_path_segment_and_parent_id(ROOT_DIR, nil)
  end

  def find_or_create_child(params)
    child = find_child params[:path_segment]
    unless child
      child = create_child params
    end
    child
  end

  def find_child(path_segment)
    SiteMapping.find_by_parent_id_and_path_segment(self.id, path_segment)
  end

  def create_child_by_path_segment(path_segment)
    create_child({:path_segment => path_segment})
  end

  def create_child(params)
    child = SiteMapping.create(params)
    add_child(child)
    child.save!
    child
  end

  # Finds all site_mappings including labels and chunk for last mappings 
  # and process labels
  def self.find_mapping_and_labels_and_chunk(path = [], version = nil, external_only = false)
    m = find_mapping(path, version, external_only)
    return nil if m.nil?

    # find chunk version
    unless version
      version = m.version
    end

    if m.chunk && m.chunk.live_chunk_version && (version.nil? || m.chunk.live_version == version)
      logger.info "Already got required chunk version"
      chunk = m.chunk.live_chunk_version
    else
      logger.info "Looking for chunk version"
      chunk = Chunk.find_version({:id => m.chunk_id, :version => version})
    end

    return m, process_labels(m), chunk
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

    include = [{ :chunk => [:live_chunk_version] }, :mapping_labels]
    include << parent_mappings if parent_mappings

    find(:first,
      :include => include,
      :conditions => conditions)
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

  def root
    SiteMapping.find_root
  end

  def root?
    super \
      || (
        (self.lft.nil? || self.lft == 0) \
        && (self.rgt.nil? || self.rgt == 0) \
        && (self.parent_id.nil? || self.parent_id == 0) \
        && SiteMapping.count == 1)
  end

  def self_and_ancestors
    return [self] if self.lft.nil?
    SiteMapping.find(:all, :conditions => "(#{self.lft} BETWEEN lft AND rgt)", :order => 'lft' )
  end

  def level
    return 0 if self.parent_id.nil?
    SiteMapping.count(:conditions => "(#{self.lft} BETWEEN lft AND rgt)") - 1
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
      tree << SiteMapping.find_root
    end

    tree
  end

  # need to drop all dependend mapping labels
  def before_destroy
    return if self.rgt.nil? || self.lft.nil?
    ids = SiteMapping.find_by_sql("select id from site_mappings where lft > #{self.lft} and rgt < #{self.rgt}")

    MappingLabel.delete_all("site_mapping_id IN (#{ids.collect(&:id).join(', ')})") unless ids.empty?
    super
  end
end
