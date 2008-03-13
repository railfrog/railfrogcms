# Sample deploy.rb
set :application, "harvest"
set :user, "root"
set :repository,  "svn+ssh://my-private-svn.com/svn/sites/harvest"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/rails/#{application}"

role :app, "www.my-vps.com"
role :web, "www.my-vps.com"
role :db,  "www.my-vps.com", :primary => true

default_run_options[:pty] = true
set :scm_username, ENV['svn_user'] || ENV['USER'] || Proc.new { Capistrano::CLI.password_prompt('SVN User: ') }
set :scm_password, Proc.new { Capistrano::CLI.password_prompt('SVN Password: ') }
