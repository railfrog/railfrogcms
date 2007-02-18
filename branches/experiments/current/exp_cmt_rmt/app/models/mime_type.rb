class MimeType < ActiveRecord::Base
  has_many :file_extensions

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
  
  
  def self.find_default_mime_type
    if !@defult_mime_type then
      @defult_mime_type = MimeType.find(:first, 
        :conditions => ["mime_type = ?", "text/html"])
    end
    @defult_mime_type
  end
  
  def self.find_by_file_ext(extension)
    mt = MimeType.find(:first, 
      :conditions => ["file_extensions.extension = ?", extension],
      :include => :file_extensions) if extension

    mt = find_default_mime_type unless mt
    
    mt
  end
end
