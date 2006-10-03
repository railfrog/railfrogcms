class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "logins", :force => true do |t|
      t.column "user_id",       :integer
      t.column "logged_in_at",  :datetime
      t.column "logged_out_at", :datetime
    end
    add_index "logins", ["user_id"], :name => "logins_user_id_index"
    
    create_table "memberships", :force => true do |t|
      t.column "user_id",    :integer
      t.column "role_id",    :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end
    add_index "memberships", ["user_id"], :name => "memberships_user_id_index"
    add_index "memberships", ["role_id"], :name => "memberships_role_id_index"
    
    create_table "permissions", :force => true do |t|
      t.column "role_id", :integer
    end
    add_index "permissions", ["role_id"], :name => "permissions_role_id_index"
    
    create_table "roles", :force => true do |t|
      t.column "parent_id",   :integer
      t.column "name",        :string
      t.column "description", :text
      t.column "created_at",  :datetime
      t.column "updated_at",  :datetime
    end
    add_index "roles", ["parent_id"], :name => "roles_parent_id_index"
    
    create_table "users", :force => true do |t|
      t.column "username",   :string
      t.column "first_name", :string
      t.column "last_name",  :string
      t.column "email",      :string
      t.column "password",   :string
      t.column "salt",       :string
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end
  end
  
  def self.down
    drop_table "logins"
    drop_table "memberships"
    drop_table "roles"
    drop_table "users"
  end
end
