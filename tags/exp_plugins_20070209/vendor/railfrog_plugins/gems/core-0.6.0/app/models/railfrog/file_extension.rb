module Railfrog
  class FileExtension < ActiveRecord::Base
    belongs_to :mime_type
  end
end