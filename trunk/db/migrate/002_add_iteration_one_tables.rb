class AddIterationOneTables < ActiveRecord::Migration
  def self.up
    
    options = 'ENGINE=InnoDB DEFAULT CHARSET=utf8'
    
    create_table :chunks, :options => options do |t|
      t.column :version,         :integer
      t.column :base_version,    :integer
      t.column :mime_type,       :string, :limit => 50
      t.column :author_email,    :string, :limit => 100
      t.column :content,         :binary
      t.column :updated_at, :datetime
    end

    create_table :live_versions, :options => options do |t|
      t.column :chunk_id,        :integer
      t.column :version,         :integer
      t.column :updated_at, :datetime
    end
    
    create_table :layouts, :options => options do |t|
      t.column :name,            :string
    end
    
    create_table :site_mappings, :options => options do |t|
      t.column :path,            :string, :null => false
      t.column :live_version_id, :integer
      t.column :version,         :integer
      t.column :layout_id,       :integer
      t.column :updated_at, :datetime
    end
    add_index :site_mappings, :path, :unique
    
  end
  
  def self.down
    drop_table :site_mappings
    drop_table :layouts
    drop_table :live_versions
    drop_table :chunks
  end
end
