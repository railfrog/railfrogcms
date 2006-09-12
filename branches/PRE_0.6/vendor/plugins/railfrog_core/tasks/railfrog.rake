require File.join(RAILS_ROOT, 'vendor', 'plugins', 'railfrog_core', 'db', 'util', 'site_loader')

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
