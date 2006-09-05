class Plugin < ActiveRecord::Base
  validates_presence_of :name, :version
  validates_format_of :version, :with => /^#{Gem::Version.const_get(:NUM_RE)}$/
  
  def validate
    if self.class.find_by_name_and_version(name, version)
      errors.add(:base, "The name-version pair of a plugin must be unique")
    end
  end
end
