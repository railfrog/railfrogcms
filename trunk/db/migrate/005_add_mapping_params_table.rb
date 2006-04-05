class AddMappingParamsTable < ActiveRecord::Migration
  def self.up
    create_table :mapping_params do |t|
      t.column :site_mapping_id, :integer
      t.column :name,            :string
      t.column :value,           :string
    end  

    remove_column :site_mappings, :layout_id
    drop_table :layouts
  end

  def self.down
    add_column :site_mappings, :layout_id, :integer
    
    create_table :layouts do |t|
      t.column :name, :string
    end
    
    drop_table :mapping_params
  end
end
