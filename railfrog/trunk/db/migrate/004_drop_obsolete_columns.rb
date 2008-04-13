

class DropObsoleteColumns < ActiveRecord::Migration
  def self.up
    change_column "site_mappings", :root_id, :integer, :default => nil
    #FIXME drop depth column
    change_column "site_mappings", :depth, :integer, :default => nil
    change_column "site_mappings", :parent_id, :integer, :default => nil
    change_column "site_mappings", :lft, :integer, :default => nil
    change_column "site_mappings", :rgt, :integer, :default => nil

    SiteMapping.find(:all, :conditions => { :root_id => 0} ).each {|sm|
      sm.root_id = nil
      sm.save
    }

    SiteMapping.find(:all, :conditions => { :parent_id => 0} ).each {|sm|
      sm.parent_id = nil
      sm.save
    }
  end

  def self.down
    change_column "site_mappings", :root_id, :integer, :default => 0
    change_column "site_mappings", :depth, :integer, :default => 0
    change_column "site_mappings", :parent_id, :integer, :default => 0
    change_column "site_mappings", :lft, :integer, :default => 0
    change_column "site_mappings", :rgt, :integer, :default => 0

    SiteMapping.find(:all, :conditions => { :root_id => nil} ).each {|sm|
      sm.root_id = 0
      sm.save
    }

    SiteMapping.find(:all, :conditions => { :parent_id => nil} ).each {|sm|
      sm.save
    }
  end
end
