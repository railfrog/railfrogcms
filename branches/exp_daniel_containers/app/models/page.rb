class Page < ActiveRecord::Base
  belongs_to :chunk
  belongs_to :container
end
