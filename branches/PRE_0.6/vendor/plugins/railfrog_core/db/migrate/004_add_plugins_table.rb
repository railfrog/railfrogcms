class CreatePlugins < ActiveRecord::Migration
  def self.up
    create_table :plugins do |t|
      t.column "name", :string
      t.column "version", :string
    end
  end

  def self.down
    drop_table :plugins
  end
end
