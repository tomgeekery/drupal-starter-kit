Drupal Starter Kit
=====================

Drupal Starter Kit is a collection of scripts to aid in local Drupal development on Ubuntu 12.04.  These scripts
have only been tested on a clean 32-bit Ubuntu 12.04 install.  Please use at your own risk.

Contents
====================
Contains two scripts:
environment_setup.sh, create_drupal_site.sh

Details
====================
The environment_setup.sh script should be run first.  It installs and/or 
enables the following: LAMP server components (Apache, MySQL, PHP), 
Additional php and misc packages (phpmyadmin, php-pear, php-gd, make, 
git), Upload Progress, Drush, mod_rewrite, Create an htdocs folder in 
the user's home directory, User name and email for git commits, Global 
.gitignore file suited well for Drupal, Geany IDE for basic code editing

The create_drupal_site.sh script will do the following: Create a 
database, Install latest stable version of Drupal, Uses a custom make 
file that installs and enables several common contributed modules, Set 
up virtual host and add entry to hosts file, Initial git commit

Usage
====================
git clone https://github.com/tomgeekery/drupal-starter-kit.git

cd drupal-starter-kit

chmod +x create_drupal_site.sh environment_setup.sh

./environment_setup.sh (follow on screen prompts)

./create_drupal_site.sh sitename (replace sitename with your desired site name)

Script will output a local URL, type it into your favorite browser's address bar and get to work!
