class User < ActiveRecord::Base
  require 'digest/sha1'

  # ToDo: Validate Email RegEx
  validates_presence_of :first_name, :last_name, :email, :password
  validates_uniqueness_of :email

  def before_save
    self[:password] = Digest::SHA1.hexdigest self[:password]
  end
end