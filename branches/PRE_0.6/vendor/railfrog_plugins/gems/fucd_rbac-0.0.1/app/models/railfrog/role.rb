class Railfrog::Role < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  has_many :permissions, :dependent => :destroy
  
  acts_as_tree #TODO: add specs
  
  validates_presence_of :name, :message => 'is required'
  
  def has_user?(user)
    users.include? user
  end
  
  def grants_permission_for?(action)
    permissions.any? { |permission| permission.grants?(action) }
  end
end
