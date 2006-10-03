class Railfrog::BaseController < ApplicationController
  layout 'railfrog'
  
  before_filter :authenticate
  
  private
    def authenticate
    end
end
