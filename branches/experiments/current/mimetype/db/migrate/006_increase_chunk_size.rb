class IncreaseChunkSize < ActiveRecord::Migration
  def self.up
    change_column(:chunk_versions, :content, :binary, :limit => 2.megabytes)
  end

  def self.down
    change_column(:chunk_versions, :content, :binary)
  end
end
