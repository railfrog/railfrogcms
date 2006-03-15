class AddIterationOneTables < ActiveRecord::Migration
  def self.up
    
    options = 'ENGINE=InnoDB DEFAULT CHARSET=utf8'
    
    create_table :chunks, :options => options do |t|
      t.column :description,     :string 
      t.column :mime_type,       :string, :limit => 50
      t.column :live_version,    :integer
      t.column :version,         :integer
      t.column :base_version,    :integer
      t.column :content,         :binary
    end
    
    Chunk.create_versioned_table :options => options 

    create_table :layouts, :options => options do |t|
      t.column :name,            :string
    end
    
    create_table :site_mappings, :options => options do |t|
      t.column :path_segment,    :string, :null => false
      t.column :chunk_id,        :integer
      t.column :version,         :integer
      t.column :layout_id,       :integer
      t.column :updated_at,      :datetime
    end

    aContent = <<END_OF_STRING
<html>
  <title>Welcome to RailFrog!</title>
  <body>
    <h1>Welcome to RailFrog CMS</h1>
    <a href="/admin">Admin pages</a>
  </body>
</html>
END_OF_STRING
    
    Chunk.create :description => "RailFrog Demo index page",
      :live_version => 1,
      :mime_type    => "application/xml+xhtml",
      :content      => aContent
      
    SiteMapping.create :path_segment => "", :chunk_id => 1
  end
  
  def self.down
    drop_table :site_mappings
    drop_table :layouts
    Chunk.drop_versioned_table
    drop_table :chunks
  end
end
