require File.join(RAILS_ROOT, 'db', 'util', 'site_loader')

namespace :rf do
  desc "Load site to database"
  task :load_site => :environment  do
    if ENV['SITE'].blank?
      raise "No SITE value given. Set SITE=db/sites/railfrog"
    else
      SiteLoader.load_site(ENV['SITE'])
    end
  end
end
