## Welcome to the Railfrog Reference Application

### Requirements

Railfrog setup currently requires the commandline - on Windows,
Start | Accessories | All Programs | Command Shell
or use Terminal or Konsole on OS/X / Linux.

You need to have the following:

  1. Ruby interpreter. See http://www.ruby-lang.org
  2. RubyGems. See http://www.rubygems.org 
  3. Rails. Run `gem install rails` (or `sudo gem install rails` on Linux or OS/X)  
     (**Note:** No longer required for Git installation - see below)
  4. SQLite, MySQL or PostgreSQL. Find full list of supported databases at
     <http://api.rubyonrails.com/files/vendor/rails/activerecord/README.html>
     - SQLite has the easiest setup and may already be installed.
  5. The mime-types gem: - `gem install mime-types`


### Installation

 * Grab our empty Rails 2.0 application with installed Railfrog:

   * If you have Git - clone the railfrog repo, then get linked resources (including Rails):

       git clone git://github.com/railfrog/railfrog.git
       git submodule update --init

   * If you prefer just to download - you'll need to install Rails.


Note:  currently Railfrog only works with Rails 2.0 and earlier. This is automatically
handled by the Git installation. 

   * download as a zip - <http://github.com/railfrog/railfrog/zipball/master>
   * download as a tarball - <http://github.com/railfrog/railfrog/tarball/master>

 Edit config/database.yml if you want to use MySQL or PostgreSQL instead of SQLite.

 * Set up the database.
   **Note:** For the current Rails 2.0.5 code you'll need Rake 0.7.3 installed:

       sudo gem i --version=0.7.3 rake
       rake _0.7.3_ db:migrate

### Getting Started

 * Change to the directory where Railfrog is unpacked, e.g. C:\apps\railfrog
Start service by running script/server and open http://localhost:3000/admin

Opening http://localhost:3000/ shows a "404 Page Not Found" error, which is correct since you haven't configured a site yet.

See the [wiki docs](http://wiki.github.com/railfrog/railfrog) for instructions on setting up your new site.


### Localization of Railfrog Control Panel

Please find Localization instruction at vendor/plugins/railfrog/README


### More info

Please find more info at vendor/plugins/railfrog/README

### Help!

If it doesn't work for you, try asking for help on the [mailing list](http://groups.google.com/group/railfrog-dev)
or on IRC - see <https://node8.cvsdude.com/trac/railfrog/cms/wiki/GettingHelp>.


We hope you find it useful.

