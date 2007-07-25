class IncreaseChunkSize < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.configurations[RAILS_ENV]['adapter'] == 'mysql'
      change_column(:chunk_versions, :content, :binary, :limit => 2.megabytes)
    end
  end

  def self.down
    if ActiveRecord::Base.configurations[RAILS_ENV]['adapter'] == 'mysql'
      change_column(:chunk_versions, :content, :binary)
    end
  end
end
