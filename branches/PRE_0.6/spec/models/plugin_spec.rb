require File.dirname(__FILE__) + '/../spec_helper'

context "Plugin class with fixtures loaded" do
  fixtures :plugins

  specify "should count two Plugins" do
    Plugin.count.should_be 2
  end

  specify "should have more specifications" do
    violated "not enough specs"
  end
end
