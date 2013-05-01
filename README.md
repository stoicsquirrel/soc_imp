SocImp - Social Importer Gem
============================

SocImp is a Ruby gem that enables your application to import and save images
from social media services. Currently supported services are Twitter,
Instagram, and Tumblr.

Installation
------------

SocImp is not yet available on RubyGems as it is very early in its development.
The easiest way is using [Bundler](http://gembundler.com/):

In your Gemfile:

    gem 'soc_imp', :git => 'git@github.com:stoicsquirrel/soc_imp.git'

In your application directory:

    $ bundle install

SocImp relies on the Twitter, Tumblr, and Instagram gems for access to their
respective services. Add them to your Gemfile as needed:

    gem 'twitter', '~> 4.0'
    gem 'tumblr_client'
    gem 'instagram'