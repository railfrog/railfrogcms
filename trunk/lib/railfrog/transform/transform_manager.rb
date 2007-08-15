require 'mime_type_tools'

module Railfrog
  module Transform

    # Maintain list of content transformers for use by SiteMapperController
    class TransformManager
      include Singleton

      def register(transformer, in_mime_type, out_mime_type)
        @transformer_table ||= []
        @transformer_table << [transformer, in_mime_type, out_mime_type]
      end
      

      # Find an appropriate transformer matching the input/output mime types and use it to transform the content.
      # Reverse-search to find the last (i.e. most-recently-added) one.
      # If the transformation fails, iterate backwards through matching transformers until one works.
      def transform!(content, in_mime_type, out_mime_type, logger = nil)
        @transformer_table.reverse_each do |tt|
          if tt[1] == in_mime_type && tt[2] == out_mime_type
            begin
              tt[0].transform!(content, in_mime_type, out_mime_type) unless tt[0].nil?
              logger.debug("run transform ok")
              return content
            rescue StandardError => e
              logger.warn "Error applying transformer #{tt[0].class.to_s}: #{e.message}" if logger
            end
          end
        end
        nil
      end
    end # class TransformManager

    class BaseTransformer
      def transform!(content, in_mime_type, out_mime_type)
        new_content = "<h2>Railfrog error: transformer not installed</h2>" + content
        content.replace(new_content)
      end
    end # class BaseTransformer

  end # module Transform
end # module Railfrog
