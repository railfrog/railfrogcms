require File.expand_path(File.dirname(__FILE__) + '/../../../../spec/spec_helper') # the default rails helper
require 'controller_mixin'
require 'rspec_on_rails'

SpecTestCase.fixture_path = File.dirname(__FILE__)  + "/fixtures/"
$LOAD_PATH.unshift(SpecTestCase.fixture_path)