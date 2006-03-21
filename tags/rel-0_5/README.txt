= RailFrog =

RailFrog is a lightweight Content Management System for building websites. 

## TODO

== Installation ==
 0. Drop {{{railfrog_development}}} database if it exists. # sorry for this. there were some changes in migration files.
 1. Create a {{{railfrog_development}}} database.
 2. Copy config/database.yml.example to database.yml and edit as appropriate.
 3. Run {{{$ rake migrate}}} to create all required tables in the database.
 4. Run WEBrick

== DONE ==
 * dropped acts_as_versioned from the Chunk model
 * refactor SiteMapper: add acts_as_threaded
 
== TODO == 
 0. add methods to add/modify/delete SiteMapping/Chunks/ChunkVersions
 1. refactor SiteMapper: add acts_as_threaded
 2. add UI to manage the sitemappings, chunks table
 3. add TTW WYSIWYG editor - Xinha

== Troubleshooting ==

 If your database gets mashed, try
 $rake migrate VERSION=0 && rake migrate

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

