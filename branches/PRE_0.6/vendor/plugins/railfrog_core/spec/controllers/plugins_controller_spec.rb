require File.dirname(__FILE__) + '/../spec_helper'

context "Rendering /plugins" do
  controller_name :plugins

  setup do
    get 'index'
  end
#
#  specify "should render 'list'" do
#    response.should_render :list
#  end
#
#  specify "should not render 'index'" do
#    lambda { response.should_render :index }.should_raise
#  end
#
#  specify "should find all plugins on GET to index" do
#    response.should_be_success
#  end

end
