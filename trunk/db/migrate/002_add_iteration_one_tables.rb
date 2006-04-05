class AddIterationOneTables < ActiveRecord::Migration
  def self.up
    options = ''
    
    create_table :chunks, :options => options do |t|
      t.column :description,     :string 
      t.column :mime_type,       :string, :limit => 50
      t.column :live_version,    :integer
    end

    create_table :chunk_versions, :options => options do |t|
      t.column :chunk_id,         :integer
      t.column :version,         :integer
      t.column :base_version,    :integer
      t.column :content,         :binary
      t.column :created_at,      :datetime
      t.column :updated_at,      :datetime
    end
    
    add_index :chunk_versions, :chunk_id
    add_index :chunk_versions, :version

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
  end

  

  def self.down
    drop_table :site_mappings
    drop_table :layouts
    drop_table :chunk_versions
    drop_table :chunks
  end
end
