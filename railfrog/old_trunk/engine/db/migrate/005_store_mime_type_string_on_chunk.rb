require 'chunk'

class Chunk < ActiveRecord::Base
  belongs_to :mime_type
end

class StoreMimeTypeStringOnChunk < ActiveRecord::Migration
  def self.up
    add_column :chunks, :mime_type_str, :string, :default => "", :limit => 100
    Chunk.reset_column_information
    # Set string mime type for each chunk
    all_chunks = Chunk.find(:all)
    all_chunks.each do |chunk|
      if chunk.mime_type_str.nil? || chunk.mime_type_str.empty?
        chunk.mime_type_str = chunk.mime_type.mime_type
        chunk.save!
      end
    end
  end

  def self.down
    remove_column :chunks, :mime_type_str
  end
end
