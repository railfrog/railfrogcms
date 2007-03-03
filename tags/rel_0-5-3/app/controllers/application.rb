class ApplicationController < ActionController::Base
  include Railfrog
  helper :prototype_window_class
  model :user
end
