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
    
    Layout.create :name => "default"
    Layout.create :name => "another"
    
    SiteMapping.create :path_segment => "", :chunk_id => 1, :parent_id => 0, :layout_id => 1, :depth => 0, :lft => 0, :rgt => 0, :root_id => 0
    SiteMapping.create :path_segment => "products", :parent_id => 0, :layout_id => 1, :depth => 0, :lft => 0, :rgt => 0, :root_id => 0
    SiteMapping.create :path_segment => "cakes", :parent_id => 2, :depth => 0, :lft => 0, :rgt => 0, :root_id => 0
    SiteMapping.create :path_segment => "chocolate_cake.html", :chunk_id => 2, :parent_id => 3, :layout_id => 2, :depth => 0, :lft => 0, :rgt => 0, :root_id => 0
  end

  def self.down
    remove_column :site_mappings, :root_id
    remove_column :site_mappings, :parent_id
    remove_column :site_mappings, :depth
    remove_column :site_mappings, :lft
    remove_column :site_mappings, :rgt
  end
end
