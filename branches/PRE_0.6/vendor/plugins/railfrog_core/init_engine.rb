module Railfrog::VERSION
  Major = 0 # change implies compatibility breaking with previous versions
  Minor = 6 # change implies backwards-compatible change to API
  Release = 0 # incremented with bug-fixes, updates, etc.
end
Engines.current.version = Railfrog::VERSION

require 'railfrog'
