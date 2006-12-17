require 'rubygems/dependency_list'

module PluginSystem
  class DependencyList < ::Gem::DependencyList
    def self.from_plugin_list(plugins)
      deps = DependencyList.new
      plugins.each do |plugin|
        deps.add(plugin.specification)
      end
      deps
    end
  end
end
