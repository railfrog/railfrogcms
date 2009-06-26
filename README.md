---
layout: default
title: Get Hopping!
---
## Welcome to Railfrog!

Railfrog is a simple and straightforward Content Management System for publishing websites.

### Requirements

We support Windows, OS/X and Linux. We expect that most people will be using a Rails-enabled web host or perhaps a VPS, and Railfrog setup currently requires that you use the commandline - but even if you have not done this before, it's very straightforward.


You need to have the following:

  1. Ruby interpreter. We currently require version 1.8.6.something, 1.8.7 isn't tested yet. Probably already there on OS/X and Linux, you can get this from <http://www.ruby-lang.org>, or Google "ruby one click installer".
  2. RubyGems. See <http://www.rubygems.org> 
  3. SQLite, MySQL or PostgreSQL. Find full list of supported databases at
     <http://api.rubyonrails.com/files/vendor/rails/activerecord/README.html>
     - SQLite has the easiest setup and may already be installed.
  4. The mime-types gem: - `sudo gem install mime-types`


### Installation

Grab our empty Rails 2.0 application with installed Railfrog.  
Note:  currently Railfrog only works with Rails 2.0 -- see instructions below.

#### Using Git 
This is the preferred technique. First [install Git](http://git-scm.com/download), then clone the railfrog repository. All required resources, including Rails, are then installed automatically.

    git clone git://github.com/railfrog/railfrog.git
    git submodule update --init

Then continue with _**Basic Configuration**_.

#### Downloading as a package

If you prefer you can just download and unpack a zip or tar file; you'll then need to install the supported version of Rails.

   * download as a zip - <http://github.com/railfrog/railfrog/zipball/master>
   * or download as a tarball - <http://github.com/railfrog/railfrog/tarball/master>

You'll then need to install version 2.0 of Rails:

    sudo gem i --version=2.0.5 rails    # you should omit the 'sudo' on Windows

### Basic Configuration

 If you want to use MySQL or PostgreSQL instead of SQLite, edit config/database.yml - see instructions in that file. SQLite is just fine while you are testing and setting up, but is not recommended for heavy-duty use.

 * Create the database.

**Note:** For the current Rails 2.0.5 code you'll need Rake 0.7.3 installed:

       sudo gem i --version=0.7.3 rake
       rake _0.7.3_ db:migrate

Change to the directory where Railfrog is unpacked, e.g. C:\apps\railfrog  
Start the Railfrog server:

    script/server

Now open a browser at http://localhost:3000/admin


### Getting Started


See the [wiki docs](http://wiki.github.com/railfrog/railfrog) for instructions on setting up your new site.

**Note:** Opening http://localhost:3000/ shows a "404 Page Not Found" error, which is correct since you haven't configured a site yet.


### Help!

If it doesn't work for you, try asking for help on the [mailing list](http://groups.google.com/group/railfrog-dev)
or on IRC - see  
<https://node8.cvsdude.com/trac/railfrog/cms/wiki/GettingHelp>.


We hope you find it useful.

