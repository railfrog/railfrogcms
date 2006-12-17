module ActiveRecord::ConnectionAdapters::SchemaStatements
  alias :plugin_system_original_initialize_schema_information :initialize_schema_information
  def initialize_schema_information
    plugin_system_original_initialize_schema_information
    begin
      create_table ::PluginSystem::Migrator::schema_info_table_name do |t|
        t.column :name,    :string
        t.column :version, :integer
      end
    rescue ActiveRecord::StatementInvalid
      # Schema has been initialized
    end
  end
end

# TODO: The migrations code is still very basic and will definitely change in the near future.
module PluginSystem
  class Migrator < ActiveRecord::Migrator
    cattr_accessor :plugin_name
    
    class << self
      def schema_info_table_name
        ::ActiveRecord::Base.table_name_prefix + "plugins_schema_info" + ::ActiveRecord::Base.table_name_suffix
      end
      
      def current_version
        if result = ::ActiveRecord::Base.connection.select_one("SELECT version FROM #{schema_info_table_name} WHERE name = '#{plugin_name}'")
          result["version"].to_i
        else
          ::ActiveRecord::Base.connection.execute("INSERT INTO #{schema_info_table_name} (version, name) VALUES (0, '#{plugin_name}')")
          0
        end
      end
    end
    
    def set_schema_version(version)
      ::ActiveRecord::Base.connection.update("UPDATE #{self.class.schema_info_table_name} SET version = #{down? ? version.to_i - 1 : version.to_i} WHERE name = '#{self.class.plugin_name}'")
    end
  end
end

ActiveRecord::SchemaDumper.ignore_tables << PluginSystem::Migrator.schema_info_table_name
