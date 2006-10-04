class PluginSystem::Database::Plugin < ActiveRecord::Base
  validates_presence_of :name, :version
  validates_format_of :version, :with => /^#{Gem::Version.const_get(:NUM_RE)}$/
  
  def validate_on_create
    if self.class.find_by_name_and_version(name, version)
      errors.add(:base, "The name-version pair of a plugin must be unique")
    end
    if self.enabled? && self.class.find_by_name_and_enabled(name, true)
      errors.add(:base, "Only one version of a plugin may be enabled")
    end
  end
  
  def full_name
    "#{name}-#{version}"
  end
end

#TODO: Don't do this automatically? What if another 'plugins' table is already present?
unless PluginSystem::Database::Plugin.table_exists?
  ActiveRecord::Schema.define do
    create_table "plugins" do |t|
      t.column "name",    :string
      t.column "version", :string
      t.column "enabled", :boolean, :default => false
    end
  end
end
