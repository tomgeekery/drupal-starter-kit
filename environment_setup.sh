#!/bin/bash

# Script is intended to take a fresh install of Ubuntu 12.04 and prepare
# it for local Drupal development.

# Update all packages.
sudo apt-get update
sudo apt-get upgrade -y

# Install lamp stack.
sudo apt-get install lamp-server^ -y

# Install extra php and misc packages.
sudo apt-get install php5-gd php-pear make git phpmyadmin -y

# Upload progress
sudo pecl install uploadprogress
sudo sh -c "echo 'extension = uploadprogress.so' > /etc/php5/apache2/conf.d/uploadprogress.ini"

# Drush
sudo pear channel-discover pear.drush.org
sudo pear install drush/drush
wget http://download.pear.php.net/package/Console_Table-1.1.3.tgz
tar xvfz Console_Table-1.1.3.tgz
sudo mv Console_Table-1.1.3 /usr/share/php/drush/lib
rm Console_Table-1.1.3.tgz
rm package.xml

# Enable rewrite
sudo a2enmod rewrite

# Setup htdocs in home folder
mkdir /home/$USER/htdocs
sudo ln -s /home/$USER/htdocs /var/www/$USER

# Setup git information.
echo -n "Enter your name for git commits: "
read GIT_NAME
echo -n "Enter your email for git commits: "
read GIT_EMAIL
git config --global user.name "'"$GIT_NAME"'"
git config --global user.email $GIT_EMAIL 
git config --global core.excludesfile .gitignore_global

# Restart apache.
sudo service apache2 restart

# Install Geany for basic code editing.
sudo apt-get install geany -y

# Display message with instructions what to do next.
echo ""
echo "Congrats!  Your Ubuntu install is ready for Drupal development."
echo "Please run './create_drupal_site.sh sitename'.  Replace"
echo "sitename with the name you wish to call your new Drupal site."
echo ""
echo "Enjoy!"
