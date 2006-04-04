class Chunk < ActiveRecord::Base
  has_many :chunk_versions
  belongs_to :mime_type
  
  def find_version(version = nil)
    Chunk.find_version({:id => self.id, :version => version })
  end

  # available options are: :id, :name, :version
  def self.find_version(options)
    if id = options[:id] then
      chunk = find(id)
    elsif name = options[:name] then
      chunk = find(:first, :conditions => ["description = ?", name])
    else
      return nil
    end

    version = options[:version] ? options[:version] : chunk.live_version
     
    chunk.chunk_versions.find(:first, :conditions => ["version = ?", version])
  end
end