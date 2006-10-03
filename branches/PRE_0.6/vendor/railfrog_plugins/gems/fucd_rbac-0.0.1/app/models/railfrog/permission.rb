class Railfrog::Permission < ActiveRecord::Base
  belongs_to :role
  
  validates_presence_of :role_id, :message => 'is required'
  
  #TODO: create this method + specs
  def grants?(action)
    true
  end
end
