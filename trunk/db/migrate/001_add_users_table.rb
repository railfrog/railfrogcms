class AddUsersTable < ActiveRecord::Migration
  def self.up
    create_table(
      :users, 
      :force => true) do |t|
      t.column :first_name, :string, :null => false
      t.column :last_name,  :string, :null => false
      t.column :email,      :string, :null => false
      t.column :password,   :string, :limit => 40, :null => false
      t.column :created_at, :datetime, :null => false, 
        :default => '1970-01-01 00:00:00'
      t.column :updated_at, :datetime, :null => false, 
        :default => '1970-01-01 00:00:00'
    end
    
    User.create :first_name => "Test", 
      :last_name  => "Tester", 
      :email      => "test@test.com", 
      :password   => "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8"
  end

  def self.down
    drop_table :users
  end
end
