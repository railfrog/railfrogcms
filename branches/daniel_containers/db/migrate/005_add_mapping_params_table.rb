class AddMappingParamsTable < ActiveRecord::Migration
  def self.up
    create_table :mapping_params do |t|
      t.column :site_mapping_id, :integer
      t.column :name,            :string
      t.column :value,           :string
    end  

    remove_column :site_mappings, :layout_id
    drop_table :layouts

    MappingParam.create :site_mapping_id => 1, :name => "layout", :value => "default"
    MappingParam.create :site_mapping_id => 1, :name => "title", :value => "Welcome to RailFrog CMS!"
    MappingParam.create :site_mapping_id => 4, :name => "layout", :value => "chunk:3"
    MappingParam.create :site_mapping_id => 4, :name => "title", :value => "Chocolate Cake"
    
    aContent = <<END_OF_STRING
<html>
  <title><%= rf_params['title'] %></title>
  <body>
    <p>header</p>
    <p>menu</p>
    <%= rf_params['chunk_content'] %>
  </body>
</html>
END_OF_STRING

    c = Chunk.create :description => "Layout", 
      :live_version => 1
    c.save

    c.chunk_versions.create :version => 1,
      :base_version => 0,
      :content => aContent
  end

  def self.down
    add_column :site_mappings, :layout_id, :integer
    
    create_table :layouts do |t|
      t.column :name, :string
    end
    
    drop_table :mapping_params
  end
end
