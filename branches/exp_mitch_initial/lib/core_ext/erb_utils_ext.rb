class ERB
  module Util
    def html_unescape(s)
      s.to_s.gsub(/&amp;/, "&").gsub(/&quot;/, "\"").gsub(/&gt;/, ">").gsub(/&lt;/, "<")
    end
    alias hu html_unescape
  end
end