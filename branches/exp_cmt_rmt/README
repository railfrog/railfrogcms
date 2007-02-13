

####################################################################
### NOTE TO DEVELOPERS                                           ###
###                                                              ###
### Development is currently happening on the PRE_0.6 branch!    ###
### Patches to this code may need work to re-integrate them -    ###
### please see branches/PRE_0.6 instead of trunk.                ###
###                                                              ###
### This is the stable branch, being used in production systems) ###
###                                                              ###
####################################################################



= RailFrog =

RailFrog is a lightweight Content Management System for building websites. 

## TODO

== Installation ==
 1. Create a {{{railfrog_development}}} database (see notes below).
 2. Copy config/database.yml.example to database.yml and edit as appropriate.
 3. Run {{{$ rake migrate}}} to create all required tables in the database.
 4. Run WEBrick

== Loading site content ==
 If you'd like to load site content to the RailFrog database use 
{{{$ rake rf:load_site SITE=<path-to-site>}}}, or use our default site 
{{{$ rake rf:load_site SITE=db/sites/railfrog}}}
  
== Troubleshooting ==

 If your database gets mashed, try
 {{{$ rake migrate VERSION=0 && rake migrate}}}

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

 
