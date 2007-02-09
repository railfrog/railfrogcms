require File.expand_path(File.dirname(__FILE__) + '/../db/util/site_loader')

namespace :railfrog do
  desc "Load site to database"
  task :load_site => :environment  do
    if ENV['SITE'].blank?
      raise "No SITE value given. Set SITE=vendor/plugins/railfrog_core/db/sites/railfrog"
    else
      SiteLoader.load_site(ENV['SITE'])
    end
  end
end
