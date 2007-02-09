module Railfrog
  module BaseHelper
    def javascript_selective_enabler
      javascript_tag "document.getElementsByClassName('js-true').each(function(e) { Element.removeClassName(e, 'js-true'); });" +
                     "document.getElementsByClassName('js-false').each(function(e) { Element.hide(e); });"
    end
  end
end
