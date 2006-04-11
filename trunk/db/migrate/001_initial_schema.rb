class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "mime_types", :force => true do |t|
      t.column "mime_type", :string
      t.column "description", :string
    end
    
    add_index "mime_types", ["mime_type"], :name => "mime_types_mime_type_index"
    
    create_table "file_extensions", :force => true do |t|
      t.column "extension", :string
      t.column "mime_type_id", :integer
    end
    
    add_index "file_extensions", ["mime_type_id"], :name => "file_extensions_mime_type_id_index"
    
    create_table "chunks", :force => true do |t|
      t.column "description", :string
      t.column "live_version", :integer
      t.column "mime_type_id", :integer
    end
    
    add_index "chunks", ["mime_type_id"], :name => "chunks_mime_type_id_index"
    
    create_table "chunk_versions", :force => true do |t|
      t.column "chunk_id", :integer
      t.column "version", :integer
      t.column "base_version", :integer
      t.column "content", :binary
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end
    
    add_index "chunk_versions", ["chunk_id"], :name => "chunk_versions_chunk_id_index"
    add_index "chunk_versions", ["version"], :name => "chunk_versions_version_index"
    
    create_table "site_mappings", :force => true do |t|
      t.column "path_segment", :string, :default => "", :null => false
      t.column "chunk_id", :integer
      t.column "version", :integer
      t.column "updated_at", :datetime
      t.column "root_id", :integer, :default => 0
      t.column "parent_id", :integer, :default => 0
      t.column "depth", :integer, :default => 0
      t.column "lft", :integer, :default => 0
      t.column "rgt", :integer, :default => 0
    end
    
    add_index "site_mappings", ["chunk_id"], :name => "site_mappings_chunk_id_index"
    add_index "site_mappings", ["path_segment", "version"], :name => "site_mappings_path_segment_index"
    add_index "site_mappings", ["parent_id"], :name => "site_mappings_parent_id_index"
    add_index "site_mappings", ["lft", "rgt"], :name => "site_mappings_lft_index"
    add_index "site_mappings", ["depth"], :name => "site_mappings_depth_index"
    
    create_table "mapping_labels", :force => true do |t|
      t.column "site_mapping_id", :integer
      t.column "name", :string
      t.column "value", :string
    end
    
    add_index "mapping_labels", ["site_mapping_id"], :name => "mapping_labels_site_mapping_id_index"
    
    create_table "users", :force => true do |t|
      t.column "first_name", :string, :default => "", :null => false
      t.column "last_name", :string, :default => "", :null => false
      t.column "email", :string, :default => "", :null => false
      t.column "password", :string, :limit => 40, :default => "", :null => false
      t.column "created_at", :datetime, :null => false
      t.column "updated_at", :datetime, :null => false
    end
    
    User.create :first_name => "Test", :last_name => "Tester", :email => "test@test.com", :password => "test"

    STDERR.puts "  loading mime types file"
    load_mime_types_file File.dirname(__FILE__) + '/mime.types.4debug'
    
    Chunk.reset_column_information
    
    set_mapping_ids_in_chunk_table
    
  end
  
  def self.down
    drop_table :users
    drop_table :site_mappings
    drop_table :chunk_versions
    drop_table :chunks
    drop_table :file_extensions
    drop_table :mime_types
    drop_table :mapping_labels
  end
  
  def self.load_mime_types_file(filename)
    File.open(filename) do |file|
      file.each do |line|
        parts = line.chomp.split
        # not empty string and not comment
        if parts.size > 0 && !(parts[0].squeeze("#") == "#") then
          mime_type = parts.delete_at(0)
          MimeType.create(mime_type, parts)
        end
      end
    end
  end
  
  def self.set_mapping_ids_in_chunk_table
    SiteMapping.find(:all, :conditions => "chunk_id is not null").each do |sm| 
      extension = sm.path_segment.chomp.split(/\./).pop
      if extension then
        fe = FileExtension.find(:first, :conditions => ["extension = ?", extension])
        sm.chunk.mime_type_id = fe.mime_type.id
        sm.save
      end
    end

    Chunk.find(:all, :conditions => "mime_type_id is null").each do |c| 
      c.mime_type_id = MimeType.find_default_mime_type.id
      c.save
    end
   end
  
end
