module PluginSystem
  module Exceptions
    class Exception < ::Exception; end
    
    class PluginAlreadyEnabledException < Exception; end
    class PluginAlreadyDisabledException < Exception; end
    class PluginAlreadyStartedException < Exception; end
    class CannotStartDisabledPluginException < Exception; end
    class CannotUninstallEnabledPluginException < Exception; end
    class SpecificationFileDoesNotExistException < Exception; end
    class PluginWithSameNameAlreadyEnabledException < Exception; end
  end
end