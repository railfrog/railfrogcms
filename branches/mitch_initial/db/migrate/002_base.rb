require File.dirname(__FILE__) + '/base'

class Base < ActiveRecord::Migration
  def self.up
    set_version('002')
    log('Base Structure')
    
    options = 'ENGINE=MyISAM DEFAULT CHARSET=utf8'
    
    create_table(:characteristics, :options => options) do |t|
      t.column :item_id,      :integer
      t.column :name,          :string
    end
    
    create_table(:extensions, :options => options) do |t|
      t.column :name,         :string
      t.column :ext_type,     :string
      t.column :temp,         :integer, :default => 0
    end
    
    create_table(:items, :options => options) do |t|
      t.column :extension_id, :integer
      t.column :name,         :string
      t.column :temp,         :integer, :default => 0
    end
    
    create_table(:options, :options => options) do |t|
      t.column :name,          :string
      t.column :value,        :string
    end
    
    create_table(:users, :options => options) do |t|
      t.column :created_at, :datetime
      t.column :login,      :string
      t.column :password,   :string
    end
    
    create_table(:permissions, :options => options) do |t|
      t.column :name,       :string
    end
    
    create_table(:roles, :options => options) do |t|
      t.column :parent_id,  :integer, :default => 0
      t.column :name,       :string
      t.column :is_default, :integer, :default => 0
    end
    
    create_table(:role_permissions, :options => options) do |t|
      t.column :role_id,        :integer, :default => 0
      t.column :permission_id,  :integer, :default => 0
      t.column :value,          :integer, :default => 0
    end
    
    create_table(:roles_users, :options => options, :id => false) do |t|
      t.column :role_id,        :integer, :default => 0
      t.column :user_id,        :integer, :default => 0
    end
    
    create_table(:item_extensions, :options => options) do |t|
      t.column :item_id,        :integer, :default => 0
      t.column :extension_id,   :integer, :default => 0
    end
    
    create_table(:role_extensions, :options => options) do |t|
      t.column :role_id,        :integer, :default => 0
      t.column :extension_id,   :integer, :default => 0
      t.column :value,          :integer, :default => 0
    end
    
    create_table(:admin_navigation_items, :options => options) do |t|
      t.column :controller,     :string
    end
    
    add_index :options, :name, :unique => true
    add_index :users, :login, :unique => true
    add_index :permissions, :name, :unique => true
    add_index :roles, :name, :unique => true
    
    log('Done')
  end

  def self.down
    set_version('002')
    log('Base Structure Teardown')
    
    drop_table :characteristics
    drop_table :extensions
    drop_table :items
    drop_table :options
    drop_table :users
    drop_table :permissions
    drop_table :roles
    drop_table :role_permissions
    drop_table :roles_users
    drop_table :item_extensions
    drop_table :role_extensions
    drop_table :admin_navigation_items
    log('Done')
  end
end
