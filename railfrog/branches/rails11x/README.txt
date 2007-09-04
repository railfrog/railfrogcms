= RailFrog =

RailFrog is a lightweight Content Management System for building websites. 

## TODO

== Prerequisites ==
* Rails 1.1.x
* Rake - {{{gem install rake}}}
* RSpec - {{{gem install rspec}}}
* BlueCloth (if you need Markdown support) - {{{gem install bluecloth}}}
* RedCloth (if you need Textile support) - {{{gem install redcloth}}}


== Installation ==
 1. Create a {{{railfrog_development}}} database (see notes below).
 2. Copy config/database.yml.example to database.yml and edit as appropriate.
 3. Run {{{$ rake db:migrate:engines:railfrog_core}}} to create all required tables in the database.
 4. Run WEBrick

== Loading site content ==
 If you'd like to load site content to the RailFrog database use 
{{{$ rake railfrog:load_site SITE=<path-to-site>}}}, or use our default site 
{{{$ rake railfrog:load_site SITE=vendor/plugins/railfrog_core/db/sites/railfrog}}}

== Troubleshooting ==

 If your database gets mashed, try
 {{{$ rake db:migrate:engines:railfrog_core VERSION=0 && rake db:migrate:engines:railfrog_core}}}

== Database Setup ==

=== MySQL ===
 * Create databases with UTF-8 as default charset:
    > CREATE DATABASE railfrog_development DEFAULT CHARACTER SET "utf8";
    > CREATE DATABASE railfrog_test DEFAULT CHARACTER SET "utf8";
    > CREATE DATABASE railfrog_production DEFAULT CHARACTER SET "utf8";
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

== Working with the Plugin System in PRE_0.6 ==
If you are looking at the new plugin code, you'll currently (04 Oct 2006) need to be doing some extra work.

 0. Install Railfrog just like always.
 1. Install Edge Rails (e.g. run {{{rake rails:freeze:edge}}})
 2. Disable Rails Engines (e.g. rename /vendor/plugins/engines/init.rb to init.rb~)
 3. Enable the "fucd_rbac" and "core" plugin: E.g. in your Rails console ({{{ruby script/console}}}) run {{{PluginSystem::Database::Plugin.update_all("enabled = true")}}}
 4. Run {{{rake db:migrate:railfrog_plugin:fucd_rbac}}} to create the tables for the "fucd_rbac" plugin 
 5. Start your development server (e.g. {{{ruby script/server}}})
 6. Locate your browser to http://localhost:3000/railfrog/login
 7. Login! Username is 'admin' and password is 'ribbet!'
