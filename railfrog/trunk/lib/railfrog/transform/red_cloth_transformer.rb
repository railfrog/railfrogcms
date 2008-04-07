module Railfrog
  module Transform

    # RedCloth is a processor for Textile content - see http://whytheluckystiff.net/ruby/redcloth/
    class RedClothTransformer < BaseTransformer
      
      def transform(content, in_mime_type, requested_mime_type, logger = nil)
        return nil, nil if content.nil?
        new_content = nil
        out_mime_type = nil
        # Only Textile to HTML transformation is supported
        return content, in_mime_type unless in_mime_type == Mime::TEXTILE.to_str && requested_mime_type == Mime::HTML.to_str
        begin
          require 'redcloth'
          new_content = RedCloth.new(content).to_html
          out_mime_type = Mime::HTML.to_str
        rescue StandardError => e
          logger.warn("Error in RedCloth processing: #{e.message}. Is the 'redcloth' gem installed?")
          new_content = content_for_error("RedCloth processor for Textile is not available", content)
        end
        return new_content, out_mime_type
      end
    end

  end
end
