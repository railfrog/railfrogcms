require File.expand_path(File.dirname(__FILE__) + '/../../../../spec/spec_helper') # the default rails helper

SpecTestCase.fixture_path = File.dirname(__FILE__) + "/fixtures"
#$LOAD_PATH.unshift(SpecTestCase.fixture_path)

RailFrog::PluginSystem::Base.root = File.expand_path(File.join(RAILS_ROOT, "vendor", "plugins", "railfrog_core", "spec", "lib", "plugin_system", "data", "gems"))