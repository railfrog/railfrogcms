class AddMimeTypesAndFileExtensionsTable < ActiveRecord::Migration
  def self.up
    STDERR.puts "Migrating to version 4"
    
    options = ''
    
    # MIME types and file extensions are from the 
    # Gentoo's app-misc/mime-types portage
    # See also:
    #  * [http://www.iana.org/assignments/media-types/ IANA MIME Media Types]
    #  * [http://en.wikipedia.org/wiki/MIME MIME Wikipedia page]
    #  * [http://framework.openoffice.org/documentation/mimetypes/mimetypes.html Mime Content Types used in OpenOffice]
    
    STDERR.puts "  creating mime_types table"
    create_table :mime_types, :options => options do |t|
      t.column :mime_type,       :string
      t.column :description,     :string 
    end
    
    STDERR.puts "  creating file_extensions table"
    create_table :file_extensions, :options => options do |t|
      t.column :extension,       :string
      t.column :mime_type_id,    :integer
    end
    
    STDERR.puts "  loading mime types file"
    load_mime_types_file File.dirname(__FILE__) + '/mime.types'
    
    add_column :chunks, :mime_type_id, :integer
    remove_column :chunks, :mime_type
    Chunk.reset_column_information
    
    set_mapping_ids_in_chunk_table
  end
  
  def self.down
    drop_table :file_extensions
    drop_table :mime_types
    
    remove_column :chunks, :mime_type_id
    add_column :chunks, :mime_type, :string
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