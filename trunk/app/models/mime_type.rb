class MimeType < ActiveRecord::Base
  has_many :file_extensions

  DEFAUL_MIME_TYPE = MimeType.find(:first, 
    :conditions => ["mime_type = ?", "application/xhtml+xml"])

  def self.create(mime_type, file_extensions)
    MimeType.new do |mt|
      mt.mime_type = mime_type
      mt.save
      file_extensions.each do |ext|
        mt.file_extensions.create :extension => ext
      end
    end
  end
  
  def self.find_by_file_name(filename)
    find_by_file_ext filename.chomp.split(/\./).pop
  end
  
  def self.find_by_file_ext(extension)
    mt = MimeType.find(:first, 
      :conditions => ["file_extensions.extension = ?", extension],
      :include => :file_extensions) if extension
puts "------------- mt: #{mt}"
    mt = DEFAUL_MIME_TYPE unless mt
    
    mt
  end
end
