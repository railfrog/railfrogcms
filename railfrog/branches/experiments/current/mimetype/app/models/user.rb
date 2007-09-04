class User < ActiveRecord::Base
  require 'digest/sha1'

  validates_presence_of :first_name, :last_name, :email, :password
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  validates_confirmation_of :password

  def before_save
    self[:password] = Digest::SHA1.hexdigest self[:password]
  end
end
