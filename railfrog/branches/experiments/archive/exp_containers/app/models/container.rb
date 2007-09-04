class Container < ActiveRecord::Base
  has_many :pages
  has_many :chunks, :through => :pages
end
