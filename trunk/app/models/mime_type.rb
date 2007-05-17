class MimeType < ActiveRecord::Base
  has_many :file_extensions

  def self.create_type_and_exts(mime_type, file_extensions)
    mt = MimeType.create :mime_type => mime_type

    file_extensions.each do |e|
      mt.file_extensions.create :extension => e
    end

    mt
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
      :include => :file_extensions,
      :conditions => ["file_extensions.extension = ?", extension]) if extension

    mt = find_default_mime_type unless mt

    mt
  end
end
