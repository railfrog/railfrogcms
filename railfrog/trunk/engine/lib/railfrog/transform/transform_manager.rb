require 'railfrog/mime_type/tools'

module Railfrog
  module Transform

    # Maintain list of content transformers for use by SiteMapperController
    class TransformManager
      include Singleton

      def register(transformer, in_mime_type, out_mime_type)
        @transformer_table ||= []
        new_row = [transformer, in_mime_type, out_mime_type]
        # Delete if already present - avoid duplicates but make sure the new transformer is at the end of the list
        @transformer_table.each_index do |i|
          row = @transformer_table[i]
          if row[0].class == transformer.class && row[1] == in_mime_type && row[2] == out_mime_type
            @transformer_table[i] = nil
          end
        end
        @transformer_table.compact!    # Remove nils
        @transformer_table << new_row
      end
      

      # Find an appropriate transformer matching the input/requested mime types and use it to transform the content.
      # Reverse-search to find the last (i.e. most-recently-added) one.
      # If the transformation fails, iterate backwards through matching transformers until one works.
      # If none match, pass back the incoming parameters
      def transform(content, in_mime_type, requested_mime_type, logger = nil)
        @transformer_table.reverse_each do |ttrow|
          if ttrow[1] == in_mime_type && ttrow[2] == requested_mime_type
            begin
              content, out_mime_type = ttrow[0].transform(content, in_mime_type, requested_mime_type) unless ttrow[0].nil?
              logger.debug("transform ok") if logger
              return content, out_mime_type
            rescue StandardError => e
              logger.warn "Error applying transformer #{ttrow[0].class.to_s}: #{e.message}" if logger
            end
          end
        end
        # None match so leave as-is:
        return content, in_mime_type
      end

      # Is a transformer registered to transform between these mimetypes?
      def handles?(in_mime_type, requested_mime_type)
        @transformer_table.reverse_each do |ttrow|
          return true if ttrow[1] == in_mime_type && ttrow[2] == requested_mime_type
        end
        false
      end
    end

  end
end
