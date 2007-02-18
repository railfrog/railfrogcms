class AddingCommentsFieldForChunkVersion < ActiveRecord::Migration
  def self.up
    add_column :chunk_versions, :comments, :string
  end

  def self.down
    remove_column :chunk_versions, :comments
  end
end
