class MappingLabel < ActiveRecord::Base
  belongs_to :site_mapping

  validates_numericality_of :site_mapping_id
  validates_uniqueness_of :name, :scope => :site_mapping_id
end
