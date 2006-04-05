require File.join(RAILS_ROOT, 'db', 'util', 'site_loader')

desc "Load site to database"
task :load_site_db => :environment do
  if ENV['SITE'].blank?
    raise "No SITE value given. Set SITE=railfrog"
  else
    SiteLoader.load_site(ENV['SITE'])
  end
end
