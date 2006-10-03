class Railfrog::Login < ActiveRecord::Base
  belongs_to :user
  
  before_create :set_login_time
  before_destroy :set_logout_time
  
  attr_accessor :username, :password
  attr_protected :user
  
  def validate
    unless user.kind_of? User
      errors.add_to_base('Invalid username or password!')
    end
  end
  
  def set_login_time
    self.logged_in_at = Time.now
  end
  
  def set_logout_time
    self.logged_out_at = Time.now
  end
  
  def initialize(attributes=nil)
    super
    if self.username && self.password
      self.user = User.find_with_credentials(self.username, self.password)
    end
  end
  
  def destroy
    save unless new_record?
    freeze
  end
  alias_method_chain :destroy, :callbacks #TODO: documentation for this line
end
