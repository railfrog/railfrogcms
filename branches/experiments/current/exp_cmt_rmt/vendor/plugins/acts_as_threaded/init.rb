require 'threaded'

ActiveRecord::Base.class_eval do
  include RailtieNet::Acts::Threaded
end
