= Railfrog =
like to load site content to the RailFrog database use

Railfrog is a lightweight Content Management System for building websites.

## TODO cleanup

== Prerequisites ==
* Rails 1.2.1 (recommended) or Edge Rails
* Rake - {{{gem install rake}}}
* RSpec (only needed for development) - {{{gem install rspec}}}
* BlueCloth (if you need Markdown support) - {{{gem install bluecloth}}}
* RedCloth (if you need Textile support) - {{{gem install redcloth}}}

== Installation ==

 1. Create a {{{railfrog_development}}} database (see notes below).
 2. Copy config/database.yml.example to database.yml and edit as appropriate.
 2.1. Freeze Rails to 1.2.1 - {{{rake rails:freeze:edge TAG=rel_1-2-1}}} (which also creates the plugins table)
 3. Enable the "core", "fucd_rbac" and "admin_ui" plugins: E.g. in your Rails console ({{{ruby script/console}}}) run {{{PluginSystem::Database::Plugin.update_all("enabled = true")}}} (you'll need to use 'enabled = 1' instead of 'enabled = true' for MySQL 4.x). Type 'exit' to leave the console.
 4. Run {{{$ rake db:migrate:railfrog_plugin:core}}} and {{{$ rake db:migrate:railfrog_plugin:fucd_rbac}}} to create all required tables in the database.
 5. Copy contents of vendor/railfrog_plugins/gems/admin_ui-0.0.1/public/ into the public/ directory
 6. Start your development server {{{$ script/server}}}
 7. Locate your browser to http://localhost:3000/railfrog/login (username is 'admin' and password is 'ribbet!')

== Loading site content ==
 If you'd 
{{{$ rake railfrog:load_site SITE=<path-to-site>}}}, or use our default site
{{{$ rake railfrog:load_site SITE=vendor/railfrog_plugins/gems/core-0.6.0/db/sites/railfrog}}}

== Database Setup ==

=== MySQL ===
 * Create databases with UTF-8 as default charset. Either
   * A: log in to the mysql database and run these commands:
    > CREATE DATABASE railfrog_development DEFAULT CHARACTER SET "utf8";
    > CREATE DATABASE railfrog_test DEFAULT CHARACTER SET "utf8";
    > CREATE DATABASE railfrog_production DEFAULT CHARACTER SET "utf8";
  or
   * B: create the databases from the commandline:
    $ mysqladmin --default-character-set=utf8 -p -u railfrog create railfrog_development
    $ mysqladmin --default-character-set=utf8 -p -u railfrog create railfrog_test
    $ mysqladmin --default-character-set=utf8 -p -u railfrog create railfrog_production

 * For each, grant privileges -- if anyone knows a tidier way to do this please shout out:
    > USE railfrog_development;
    > GRANT ALL ON railfrog_development.* TO 'railfrog'@'localhost' IDENTIFIED BY 'ribbet!'
    > USE railfrog_test;
    > GRANT ALL ON railfrog_test.* TO 'railfrog'@'localhost' IDENTIFIED BY 'ribbet!'
    > USE railfrog_production;
    > GRANT ALL ON railfrog_production.* TO 'railfrog'@'localhost' IDENTIFIED BY 'ribbet!'

=== PostgreSQL ===
 * edit /var/lib/postgresql/data/pg_hba.conf to add a suitable auth rule
 * use createuser / createdb to create dbs -- or:
    psql -U postgres template1
    > create database railfrog_development with encoding = 'utf8';
    > create database railfrog_test with encoding = 'utf8';
    > create database railfrog_production with encoding = 'utf8';
    > create user railfrog with password 'ribbet!';

== We Need You!
Please feel free to contribute to the Railfrog project.
Visit us at http://railfrog.com
