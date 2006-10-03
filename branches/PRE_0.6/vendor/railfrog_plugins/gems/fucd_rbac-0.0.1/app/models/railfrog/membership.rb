class Railfrog::Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  
  validates_presence_of :user_id, :role_id, :message => 'is required'
end
