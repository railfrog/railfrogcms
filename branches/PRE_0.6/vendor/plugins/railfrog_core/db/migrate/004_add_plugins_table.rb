class AddPluginsTable < ActiveRecord::Migration
  def self.up
    create_table :plugins do |t|
      t.column "name", :string
      t.column "version", :string
      t.column "enabled", :boolean, :default => false
    end
  end

  def self.down
    drop_table :plugins
  end
end
