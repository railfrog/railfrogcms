module Railfrog
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

    # TODO: is this the right thing to be doing to select mime 'classes' such as 'image' or 'media'?
    def self.find_by_class(name)
      types = Array.new

      case name
        when 'html', 'document'    # FIXME should use class document for generic use, html only for application/xml+xhtml etc.
          types << "= 'text/html'" << "= 'text/css'" << "= 'text/x-markdown'" << "= 'text/x-textile'"
        when 'image'
          types << "LIKE 'image/%'"
        when 'media'
          types << "LIKE 'image/%'"
        when 'markdown'
          types << "= 'text/x-markdown'"
        when 'textile'
          types << "= 'text/x-textile'"
        when 'other'
          types << "= 'text/calendar'" << "= 'text/comma-separated-values'" << "'= 'text/directory'"
          types << "= 'text/english'" << "= 'text/enriched'" << "= 'text/h323'"
      end

      conditions = ''

      types.each_index do |i|
        # FIXME: is this susceptible to SQL injection???
        conditions << "(mime_type #{types[i]})"
        conditions << ' OR ' if (i < types.length-1)
      end

      MimeType.find(:all, :conditions => conditions)
    end
  end
end
