require 'railfrog/mime_type/tools'

module Railfrog
  module Transform
    
    class BaseTransformer
      def transform!(content, in_mime_type, out_mime_type)
        return nil if content.nil?
        custom_message = "Railfrog error: transformer not installed"
        content.replace(content_for_error(custom_message, content))
      end

      def content_for_error(custom_message, raw_content)
        msg =  "<div class='railfrog-error'><p style='color:red'>We're sorry, this content cannot be processed.<br/>"
        msg += custom_message + "<br/>" if custom_message
        msg += "The site administrator has been notified.<br/>"
        msg += "Here is the unprocessed content:</p>"
        msg += "<p><pre>"
        msg += raw_content
        msg += "</pre></p></div>"
      end
      
    end

  end
end
