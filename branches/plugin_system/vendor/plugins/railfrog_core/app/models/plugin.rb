class Plugin < ActiveRecord::Base
  serialize :version
  
  attr_accessor :spec
  
  validates_uniqueness_of :version, :scope => :name
  
  def after_initialize
    @spec = RailFrogPluginAPI::find_plugin(self.name, self.version)
  end
  
  class << self
    def find_enabled
      find(:all, :conditions => "enabled = 1" )
    end
  end
end