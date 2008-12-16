module Railfrog
  module MimeType

    require 'mime/types'

    # Utilities for handling MIME types
    # MIME support is available
    #   * in Rails Mime::Type (though few types are preloaded as of June 2007)
    #   * in the 'mime-types' gem, currently bundled as a plugin, which defines MIME::Type and MIME::Types
    #--
    # The MimeType and FileExtension models used in Railfrog up to 0.5.4 are being removed in favour of Mime::Type
    #++
    # Rails 1.2.x has neither a comprehensive list of types nor a lookup mechanism by extension - so we
    # fake them out using the MIME::Type (gem) code while keeping Mime::Type as the primary representation.
    class Tools
      @@custom_types_loaded = false
      
      # returns: Mime::Type or nil    
      def self.find_by_file_name(filename)
        find_by_file_ext filename.chomp.split(/\./).pop
      end
      
      def self.find_default_mime_type
        Mime::Type.lookup("text/html")
      end
      
      # returns: Mime::Type or nil
      def self.find_by_file_ext(extension)
        lazy_load
        mts = MIME::Types.of(extension)
        mt = mts[0] unless !mts
        mt = find_default_mime_type unless mt
        Mime::Type.lookup(mt.to_s)
      end
      
      # Return a lowercase Symbol for this mime_type - eg :markdown for text/x-markdown
      def self.markup_for_mime_type(mt_in)
        mt = Mime::Type.lookup(mt_in)
        (mt == nil) ? :nil : mt.to_sym
      end
      
      # TODO:REFACTOR ]The register method matches the 2007-06-27 Edge Rails syntax
      # Here it is being used also to update the non-Rails MIME::Type repository
      # returns: Mime::Type
      def self.register(string, symbol, mime_type_synonyms = [], extension_synonyms = [])
        # Create a new entry in the MIME registry
        mt = MIME::Type.new(string) do |t|
          t.extensions = (symbol) ? symbol.to_s.to_a : []
          t.extensions.concat(extension_synonyms) unless extension_synonyms == nil
          t.registered = false    # This is not an officially registered IANA mime type
        end
        MIME::Types.add(mt)
        # Now add to the Rails Mime::Type registry
        # TODO:REFACTOR once Edge  Mime::Type.register(string, symbol, mime_type_synonyms, extension_synonyms) is golden
        Mime::Type.railfrog_register(string, symbol, mime_type_synonyms, extension_synonyms)
      end
      
      
      private
      
      def self.lazy_load
        if !@@custom_types_loaded
          # See thread http://www.mail-archive.com/markdown-discuss@six.pairlist.net/msg00654.html for list of Markdown extensions
          register("text/x-markdown", :markdown, [], 
                   %w{ md mdown mkdwn mark markdn mdtext mdml mkd })
          register("text/x-textile", :textile, [])
          register("application/x-javascript", :javascript, [], %w{ js } )
          @@custom_types_loaded = true
        end
        # TODO:REFACTOR once Edge code is golden - may choose to drop MIME::Type gem and load from file with:
        #    if !@@custom_types_loaded
        #      mime_file =  File.dirname(__FILE__) + '../db/migrate/mime.types.apache2'
        #      load_mime_types(mime_file)
        #    end
      end
      
      
      
      #   # Load mime types from an Apache-format file
      #   # From WEBrick::HTTPutils - thanks!
      #   def load_mime_types(filename)
      #     begin
      #       File.open(filename) { |f|
      #         f.each { |line|
      #           next if /^#/ =~ line
      #           line.chomp!
      #           mimetype, ext0 = line.split(/\s+/, 2)
      #           next unless ext0   
      #           next if ext0.empty?
      #           next if Mime.const_defined? ext0 # already registered
      #           ext0.split(/\s+/).each { |ext|
      #             Mime::Type.register(mimetype, ext) 
      #           }
      #         }
      
      #       }
      #     end
      #   end
      
      
    end
    ### end

  end # module MimeType
end # module Railfrog

# Extending Rails 1.2.3 Mime::Type to handle extensions (as supported by Edge Rails 2007-06-27)
module Mime
  class Type
    def self.railfrog_register(string, symbol, mime_type_synonyms, extension_synonyms)
      new_mt = Mime::Type.register(string, symbol, mime_type_synonyms)
      extension_synonyms.each {|e| EXTENSION_LOOKUP[e.downcase] = new_mt} if extension_synonyms
    end
  end
end

