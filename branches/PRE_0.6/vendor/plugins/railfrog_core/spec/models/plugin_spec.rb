require File.dirname(__FILE__) + '/../spec_helper'

context "Plugin class with fixtures loaded" do
  fixtures :plugins
  
  specify "name-version pair should be unique" do
    2.times do
      bubba = Plugin.create(:name    => "bubba",
                            :version => "0.4.0")
    end
    Plugin.count(:conditions => ["name = ? AND version = ?", "bubba", "0.4.0"]).should_be 1
  end
end
