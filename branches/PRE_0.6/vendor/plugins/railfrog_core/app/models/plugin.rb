class Plugin < ActiveRecord::Base
  validates_uniqueness_of :version, :scope => :name
end
