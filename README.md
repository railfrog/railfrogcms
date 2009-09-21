---
layout: default
title: Get Hopping!
---

*Software, like water, is best when fresh! This information is up to date as of 2009-06-30*.

## Welcome to Railfrog!

Railfrog is a simple and straightforward Content Management System for publishing websites.

### Beware! There are two of them!

The first thing you must know is that Railfrog comes in two flavours. 

* First we have **Railfrog** itself: this is a *Ruby on Rails Engine* and you will find it at <http://github.com/railfrog/railfrog/tree/master>.

* Then we have the **Railfrog Content Management System** which is an application using the Railfrog engine to build a simple CMS. You can find it at <http://github.com/railfrog/railfrogcms/tree/master>.

The Railfrog engine can be integrated into any Ruby on Rails application, effectively extending the application with simple content management capabilities. You will use the Railfrog engine if you are developing Ruby on Rails applications yourself, or if you are contributing back to the Railfrog project.

The Railfrog CMS is a simple ready to use content management system. You will use this one if you just want to get started using Railfrog as standalone web publishing tool. You will probably also want to start with RailfrogCMS if you are just beggining to explore Railfrog's capabilities. 

We strongly suggest that you start with RailfrogCMS, and the remainder of these instructions will assume this is the case. Once you are familiar with RailfrogCMS, using the Railfrog engine in your own projects is covered in the [project documentation](<http://github.com/railfrog/railfrog/tree/master>).

### Requirements

Railfrog is built on top of Ruby on Rails, and runs anywhere you can get Ruby on Rails running: that is, on most current platforms, including Windows, Mac OS/X and Linux. We expect that most people will be using a Rails-enabled web host or perhaps a VPS to deploy their application, and perhaps a laptop if you want a separate system for for testing and development.

You need to have the following:

  1. **Ruby interpreter**. We currently require Ruby version 1.8.6. Note that Ruby 1.8.7 is not currently supported. If you are on Mac OS/X or on Linux, you will most likely have Ruby available; otherwise you can get it from <http://www.ruby-lang.org>. If you are on Windows, the quickest way to get ruby is using the [Ruby one click installer](http://rubyforge.org/projects/rubyinstaller/).
  2. **RubyGems**. Again, this may already be installed; on Windows it's included in the "one click installer". If you don't yet have it, see the [RubyGems manual](http://rubygems.org/read/chapter/3) for installation instructions.
  3. **SQLite**, **MySQL** or **PostgreSQL**. There's also a [long list of other databases for use with Rails](http://api.rubyonrails.com/files/vendor/rails/activerecord/README.html) which we haven't tested, please let us know if you have problems with one of these.
  4. **Git**. If you do not have git on your system, see "[Install Git](http://git-scm.com/download)". On Windows we recommend the msysGit "official full installer" package.  Git will be used to clone the railfrogcms repository; all required resources, including the appropriate version of Rails, will then be installed automatically.

If you want to do more than just install the Railfrog CMS and publish a website, you should be familiar with Ruby on Rails. If you are not, then you might want to go through the [Getting Started with Rails](http://guides.rubyonrails.org/getting_started.html) guide.

Before you proceed with installation, you may want to make sure you are able to create and start a simple Ruby on Rails application. This is not required, but will reassure you that you have all the required bits and pieces installed and running (the ruby interpreter, the database, the web server, etc.). If you're on Windows, this [tutorial on setting up Rails in Windows](http://railstutor.org/projects/rails-tutor/wiki/Windows) may save you some pain.

While you might have Ruby on Rails already installed on your system (or you installed it yourself following the above mentioned Getting Started guide), when you perform the following instructions to install the Railfrog CMS, you will get a specific version of Rails installed under the *vendor* directory. This is to ensure that Railfrog runs against the specific version of Rails that is needed (and that one might *not* be the same as the one that is already installed on your computer).

## Installation

Railfrog setup currently requires that you use a commandline "shell" (called Command Prompt, Terminal or Konsole on various platforms) - but even if you have not done this before, it's very straightforward.

**Note:** In the following instructions we are prefixing all the commands with "sudo", which is what you need to gain administrator privileges on Linux and Mac. If you are on Windows, type the same commands at the "C:\\\>" prompt (Start | All Programs | Accessories | Command Prompt), but without the "sudo".

### Step 1. Ensure you Have the Right Gems 

The Railfrog engine needs a few ruby gems.

**DO THIS:**

Start a commandline shell and type:

    sudo gem install mime-types maruku RedCloth

Note that capitalisation is important; it's RedCloth, not redcloth.

### Step 2. Ensure you Have the Right Version of Rake

At the time of writing, Raifrog requires Rails 2.0.5. As mentioned earlier, you'll get that version of Rails when you clone the Railfrog CMS repository following these instructions. However, another dependency that is not resolved automatically is on the corresponding version of Rake. You must ensure you have the correct version of Rake available on your system (and then that you use it when migrating the database, as explained later). You can have multiple versions installed at the same time.

**DO THIS:**

    sudo gem install --version=0.7.3 rake

### Step 3. Clone the RailfrogCMS Repository

First create a working directory - for example, `/Users/pris/dev` or `C:\dev`. Change to this directory:

`cd /Users/pris/dev`

Use git to download the RailfrogCMS files from the github repository. The files will be downloaded into a `railfrogcms` directory within your working directory:

**DO THIS:**

    git clone git://github.com/railfrog/railfrogcms.git

Now change to the `railfrogcms` directory:

**DO THIS:**

    cd railfrogcms

### Step 4. Fetch the Git Submodules

With this step you will fetch the correct version of Rails and any other required components and install them into the `vendor` sudirectory of `railfrogcms`. Beware that this step might take a little while to download, since Rails is a large and sophisticated framework:

**DO THIS:**

    git submodule update --init

You will notice that after this step you will have a number of new directories under `vendor`. In addition to `vendor/rails`, notice that you now have `vendor/plugins/railfrog`: this is the actual Railfrog engine. You'll get the latest version of the Railfrog engine that is tested to work with RailfrogCMS.

### Step 5. Configure Your Database Connection

 The default is to use SQLite. If you want to use MySQL or PostgreSQL instead, edit `config/database.yml`. (For instructions about how to do that, check the various Ruby on Rails tutorials.)

 If you decide to use SQLite, then you can skip this step because you do not have to change `config/database.yml`: it comes preconfigured for SQLite.

 Note: SQLite is just fine while you are testing and setting up, but is not recommended for heavy-duty use.

### Step 6. Create the Database

 Assuming that your database connection is configured properly, you can now create the database by running the migrate script. Here you'll use Rake version 0.7.3, the version that you previously installed in Step 2.

**DO THIS:** (and, Yes!, you have to type those underscores...)

       rake _0.7.3_ db:migrate

### Step 7. Start The Server and Open Railfrog

Start the Railfrog server:

**DO THIS:**

    script/server

Rails will output status messages as it starts up; any problems with your setup will usually result in error messages being displayed here.

Now open a browser at <http://localhost:3000/admin> and you should see the Railfrog administration interface.

**Note:** Opening http://localhost:3000/ will show a "404 Page Not Found" error, which is correct since you haven't configured a site yet. To configure the site you'll use the administration interface.

## Next Steps

See the [wiki docs](http://wiki.github.com/railfrog/railfrog) for instructions on setting up your new site. Once you have it working, you'll probably want to check the deployment documentation and deploy to a public server.

If it doesn't work for you, try asking for help on the [mailing list](http://groups.google.com/group/railfrog-dev)
or on the `#railfrog` irc channel on `irc.freenode.net`.


We hope you find it useful - if you do, please consider contributing ideas, suggestions -- or even code -- to help us achieve our goal:

**Design, Deploy and Maintain Websites -- with Joy!**

