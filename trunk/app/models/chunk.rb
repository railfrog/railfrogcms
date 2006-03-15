require "acts_as_versioned"

class Chunk < ActiveRecord::Base
  acts_as_versioned
  
  def self.find_live_version(id)
    chunk = find(id)
    find_version(id, chunk.live_version)
  end
end