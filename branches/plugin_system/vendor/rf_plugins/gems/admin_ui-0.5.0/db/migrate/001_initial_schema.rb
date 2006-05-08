class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "plugins2", :force => true do |t|
      t.column "name", :string
      t.column "version", :string
      t.column "enabled", :boolean
      t.column "installed", :boolean
      t.column "options", :text
    end
  end
  
  def self.down
    drop_table :plugins2
  end
end