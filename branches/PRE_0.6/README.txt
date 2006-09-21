= RailFrog =

RailFrog is a lightweight Content Management System for building websites. 

## TODO

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

=== PostgreSQL ===
 * edit /var/lib/postgresql/data/pg_hba.conf to add a suitable auth rule
 * use createuser / createdb to create dbs -- or:
    psql -U postgres template1
    > create database railfrog_development with encoding = 'utf8';
    > create database railfrog_test with encoding = 'utf8';
    > create database railfrog_production with encoding = 'utf8';
    > create user railfrog with password 'ribbet!';


== Working with PRE_0.6 ==
If you are looking at the new plugin code, you'll currently (21 Sep 2006) need to be doing some extra work. These are some rough notes from IRC:
http://www.xmlv.com/railfrog/irclogs/railfrog.log.20060915
which have received only minimal testing:

0) rake rails:freeeze:edge
1) edge_rails = true in /vendor/plugins/railfrog/init.rb
2) rename init.rb in /vendor/plugins/engines/ to init.rb~
3) comment out the line about the SiteMapper in config/routes.rb
4) comment out Engines.start lines in config/environment.rb
5) start server
(this creates the plugins table)
6) change the value of enabled (default = 0) for the hello_world plugin in the plugins table to 1 (true)
7) stop the server and start it again


ruby script/server
then open your favourite sql tool
and in the plugins table of your pre06 database you should see 1 entry
in the enabled column: change 0 to 1
then save your changes
then stop the started server (i.e. Ctrl+C)
and start the server again
you can also use ruby script/console to change the plugin from disabled to enabled:
@plugin = Plugin.find(:first)
@plugin.enabled = true
@plugin.save
