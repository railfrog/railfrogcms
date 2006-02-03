class Page < ActiveRecord::Migration
  def self.up 
    options = 'ENGINE=MyISAM DEFAULT CHARSET=utf8'
    
    create_table(:page_items, :options => options) do |t|
      t.column :page_id,      :integer, :default => 0
      t.column :item_id,      :integer, :default => 0
      t.column :location,     :string
    end
  end

  def self.down
    drop_table :page_items
  end
end
