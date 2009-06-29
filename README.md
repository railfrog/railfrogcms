---
layout: default
title: Get Hopping!
---

*Software, like water, is best when fresh! This information is actual as of 2009-06-29*.

## Welcome to Railfrog!

Railfrog is a simple and straightforward Content Management System for publishing websites.

### Beware! There are two of them!

The first thing you must know is that Railfrog comes in two flavours. 

* First we have **Railfrog** as such: it is a *Ruby on Rails Engine* and you will find it at <http://github.com/railfrog/railfrog/tree/master>.

* Then we have the **Railfrog Content Management System** which is a sample application using the Railfrog engine to build a simple CMS. You can find it at <http://github.com/railfrog/railfrogcms/tree/master>.

The Railfrog engine can be integrated into any Ruby on Rails application, effectively extending such application with simple contente management system capabilities. You will use the Railfrog engine if you are developing Ruby on Rails applications yourself; or if you are contributing back to the Railfrog code itself.

The Railfrog CMS is a simple ready to use content management system. You will use this one if you just want to get started using the Railfrog as standalone web publishing tool. You will probably also want to start with the RailfrogCMS if you are just beggining to explore Railfrog's capabilities. 

We strongly suggest that you start with RailfrogCMS, and the remainder of these instructions will assume this is the case. Once you are familiar with RailfrogCMS, you will probably be able to use the Railfrog engine by yourself.

### Requirements

Railfrog is built on top of Ruby on Rails, and runs anywhere you can get Ruby on Rails running. That is on most current platforms like Windows, Mac OS/X and Linux. We expect that most people will be using a Rails-enabled web host or perhaps a VPS.

You need to have the following:

  1. **Ruby interpreter**. We currently require Ruby version 1.8.6. Note that Ruby 1.8.7 is not currently supported. If you are on Mac OS/X or on Linux, you will most likely have Ruby available; otherwise you can get it from <http://www.ruby-lang.org>. If you are on Windows, the quickest way to get ruby is thrught the [Ruby one click installer](http://rubyforge.org/projects/rubyinstaller/).
  2. **RubyGems**. See <http://www.rubygems.org> 
  3. **SQLite**, **MySQL** or **PostgreSQL**. Find full list of supported databases at <http://api.rubyonrails.com/files/vendor/rails/activerecord/README.html>. 
  4. **Git**. If you do not have git on your system, see [install Git](http://git-scm.com/download).
  Git will be used then clone the railfrogcms repository, and all required resources, including the appropriate version of Rails, are then installed automatically.

You should be familiar with Ruby on Rails. If you are not, then you might want to go through the [Getting Started with Rails](http://guides.rubyonrails.org/getting_started.html) guide.

Before you proceed with installing Railfrog, make sure you are able to create and start a simple Ruby on Rails application. This will reassure you that you have all the required bits and pieces installed and running (the ruby interpreter, the database, the web server, etc.).

While you might have Ruby on Rails already installed on your system (or you installed it yourself following the above mentioned Getting Started guide), when you perform the following instructions to install the Railfrog CMS, you will get a specific versin of Rails installed under the *vendor* directory. This is to ensure that Railfrog runs against the specific version of Rails that is needed (and that one might *not* be the same as the one that is installed on your computer).

## Installation

Railfrog setup currently requires that you use the commandline - but even if you have not done this before, it's very straightforward.

**Note:** In the following instructions we are prefixing all the commands with "sudo", which is what you need to gain administrator privileges on linux and Mac. If you are on Windows, type the same commands at the DOS prompt, but without the "sudo".

### Step 1. Ensure you Have the Right Gems 

The Railfrog engine needs a few ruby gems.

**DO THIS:**

    sudo gem install mime-types maruku RedCloth

### Step 2. Ensure you Have the Right Version of Rake

At the time of writing, Raifrog requires Rails 2.0.5. As mentioned earlier, you will get that version of Rails when you clone the Railfrog CMS repository following these instructions. However, another dependency that is not resolved automatically is on the corresponding version of Rake. You must ensure you have the correct version of Rake on your system (and then that you use it when migrating the database, as explained later).

**DO THIS:**

    sudo gem install --version=0.7.3 rake

### Step 3. Clone the Railfrog CMS Repository

Use git to download the Railfrog CMS files from the github repository. You should do the following inside whatever working directory you have. The files will be copied into a *railfrogcms* directory off your working directory.

**DO THIS:**

    git clone git://github.com/railfrog/railfrogcms.gitk

Now move into the *railfrogcms* directory:

**DO THIS:**

    cd railfrogcms

### Step 4. Clone the Git Submodules

With this step you will make sure you get the correct version of Rails and any other vital components installed into the *vendor* directory off the *railfrogcms* directory. Beware that this step might take a little while, but it is essential that you perform it.

**DO THIS:**

    git submodule update --init

You will notice that after this step you will have a number of new directories under *vendor*. In particular, in addition to *rails*, notice that you now have *plugins/railfrog* there: it is the actual railfrog engine. This means that you now have configured Railfrog CMS to use the Railfrog engine.

### Step 5. Configure Your Database Connection

 If you want to use MySQL or PostgreSQL instead of SQLite, edit *config/database.yml*. (For instructions about how to do that, check the various Ruby on Rails tutorials.)

 If you decide to use SQLite, then you can skip this step because you do not have to change *config/database.yml* at all: you will find it preconfigured specifically for SqlLite.

 Note: SQLite is just fine while you are testing and setting up, but is not recommended for heavy-duty use.

### Step 6. Create the Database.

 Assuming that your database connection is configured properly, you can now creae the database by running the migrate script. It is at this point that you must ensure to use Rake version 0.7.3 that you previously installed in Step 2.

**DO THIS:** (and, Yes!, you have to type those underscores...)

       rake _0.7.3_ db:migrate

### Step 7. Start The Server and Open Railfg

Start the Railfrog server:

**DO THIS:**

    script/server

Now you can open a browser at <http://localhost:3000/admin> and you should see Railfrog CMS's administration interface.

**Note:** Opening http://localhost:3000/ will show a "404 Page Not Found" error, which is correct since you haven't configured a site yet. To configure the site, use the administration interface.

## Next Steps

See the [wiki docs](http://wiki.github.com/railfrog/railfrog) for instructions on setting up your new site.

If it doesn't work for you, try asking for help on the [mailing list](http://groups.google.com/group/railfrog-dev)
or on the *#railfrog* irc channel on *irc.freenode.net*.


We hope you find it useful.

