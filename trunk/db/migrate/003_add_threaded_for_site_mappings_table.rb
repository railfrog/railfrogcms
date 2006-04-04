class AddThreadedForSiteMappingsTable < ActiveRecord::Migration
  def self.up
    add_column :site_mappings, :root_id, :integer
    add_column :site_mappings, :parent_id, :integer
    add_column :site_mappings, :depth, :integer
    add_column :site_mappings, :lft, :integer
    add_column :site_mappings, :rgt, :integer
    
    # for better performance of the acts_as_threaded lookups
    add_index :site_mappings, :path_segment
    add_index :site_mappings, :parent_id
    add_index :site_mappings, [:lft, :rgt]
    add_index :site_mappings, :depth
  end

  def self.down
    remove_column :site_mappings, :root_id
    remove_column :site_mappings, :parent_id
    remove_column :site_mappings, :depth
    remove_column :site_mappings, :lft
    remove_column :site_mappings, :rgt
  end
end
