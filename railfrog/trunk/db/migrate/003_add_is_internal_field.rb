class AddIsInternalField < ActiveRecord::Migration
  def self.up
    add_column "site_mappings", :is_internal, :boolean, :default => false
  end

  def self.down
    remove_column "site_mappings", :is_internal
  end
end
