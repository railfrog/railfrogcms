require 'fileutils'
require File.join(RAILS_ROOT, 'config', 'environment')
require File.dirname(__FILE__) + '/../lib/railfrog/site_loader'

namespace :railfrog do

  namespace :site do

    desc "Load site to database. Set path to the site directory using SITE=<path>"
    task :load => :cleanup do
      if ENV['SITE'].blank?
        raise "No SITE value given. Set SITE=db/sites/railfrog"
      else
        Railfrog::SiteLoader.load_site(ENV['SITE'])
      end
    end

    desc "Dump site to file system. Set path to the site directory using SITE=<path>"
    task :dump => :environment  do
      if path = ENV['SITE']
        FileUtils.mkdir_p(path)
        Railfrog::SiteLoader.dump_site(path)
      else
        raise "No SITE path given. Set SITE=db/sites/railfrog"
      end
    end

    desc "Cleanup database"
    task :cleanup => :environment  do
      MappingLabel.delete_all
      SiteMapping.delete_all
      ChunkVersion.delete_all
      Chunk.delete_all
    end

  end

  namespace :fixtures do
    desc "Dumps data from all tables to fixtures"
    task :dump => :environment  do
      SKIP_TABLES = %w{ schema_info }
      (ActiveRecord::Base.connection.tables - SKIP_TABLES).each do |table|
        begin
          puts "Dumping data from the #{table} table"
          Object.const_set("SourceRecord", Class.new(ActiveRecord::Base))
          SourceRecord.set_table_name table
          SourceRecord.to_fixture
        rescue => exc
          STDERR.puts exc.message
          STDERR.puts exc.backtrace.join("\n")
        end
      end
    end
  end
end


