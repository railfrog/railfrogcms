require 'fileutils'
require File.join(RAILS_ROOT, 'config', 'environment')
require File.join(RAILS_ROOT, 'lib', 'site_loader')

namespace :railfrog do

  namespace :site do

    desc "Load site to database. Set path to the site directory using SITE=<path>"
    task :load => :environment  do
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

end
