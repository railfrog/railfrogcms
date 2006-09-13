ActiveRecord::Schema.define do
  create_table :plugins do |t|
    t.column "name", :string
    t.column "version", :string
    t.column "enabled", :boolean, :default => false
  end
end